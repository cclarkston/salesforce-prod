/*
2016-12-12 Alon Waisman
Consult_Inventory.trigger - 96%
*/

@isTest
private class test_Consult_Inventory_trigger {

	private static Consult_Inventory__c[] appointments;
	private static Consult_Inventory__c appointment1;
	private static Consult_Inventory__c appointment2;
	private static Consult_Inventory__c appointment3;

	private static void init() {
		Center_Information__c center = new Center_Information__c(latlong__Latitude__s = 0, latlong__Longitude__s = 0);
		insert center;
		Consult_Rooms__c room = new Consult_Rooms__c(Center_Information__c = center.ID);
		insert room;
		appointment1 = new Consult_Inventory__c(Consult_Room__c = room.ID, Apt_Date__c = Date.today(), Start_Hour__c = '10', Start_Minute__c = '0', End_Hour__c = '11', End_Minute__c = '0');
		appointment2 = new Consult_Inventory__c(Consult_Room__c = room.ID, Apt_Date__c = Date.today(), Start_Hour__c = '11', Start_Minute__c = '0', End_Hour__c = '12', End_Minute__c = '0');
		appointment3 = new Consult_Inventory__c(Consult_Room__c = room.ID, Apt_Date__c = Date.today(), Start_Hour__c = '12', Start_Minute__c = '0', End_Hour__c = '13', End_Minute__c = '0');
		appointments = new Consult_Inventory__c[]{appointment1, appointment2, appointment3};
		insert appointments;
	}

	static testMethod void test_double_consult_reciprocity_when_added() {
		init();

		test.startTest();
			appointment1.Double_Consult__c = appointment2.ID;
			update appointment1;
		test.stopTest();

		appointment2 = appointment_from_db(appointment2);
		system.AssertEquals(appointment1.ID, appointment2.Double_Consult__c);
	}

	static testMethod void test_double_consult_reciprocity_when_removed() {
		init();

		appointment1.Double_Consult__c = appointment2.ID;
		appointment2.Double_Consult__c = appointment1.ID;
		update appointments;
		Util_TriggerContext.alreadyProcessed = false;

		test.startTest();
			appointment1.Double_Consult__c = null;
			update appointment1;
		test.stopTest();

		appointment2 = appointment_from_db(appointment2);
		system.AssertEquals(null, appointment2.Double_Consult__c);
	}

	static testMethod void test_double_consult_reciprocity_when_changed() {
		init();

		appointment1.Double_Consult__c = appointment2.ID;
		appointment2.Double_Consult__c = appointment1.ID;
		update appointments;
		Util_TriggerContext.alreadyProcessed = false;

		test.startTest();
			appointment1.Double_Consult__c = appointment3.ID;
			update appointment1;
		test.stopTest();

		appointment2 = appointment_from_db(appointment2);
		appointment3 = appointment_from_db(appointment3);
		system.AssertEquals(null,            appointment2.Double_Consult__c);
		system.AssertEquals(appointment1.ID, appointment3.Double_Consult__c);
	}


	private static Consult_Inventory__c appointment_from_db(Consult_Inventory__c appointment) {
		return [SELECT Double_Consult__c FROM Consult_Inventory__c WHERE ID = :appointment.ID];
	}


}