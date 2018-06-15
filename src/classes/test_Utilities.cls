/*
2016-07-05 Alon Waisman
Utilities - 100%
*/

@isTest
private class test_Utilities {

	static testMethod void test_picklist_values() {
		String[] expected_list = new String[]{'TV', 'Newspaper', 'Radio', 'Flyer', 'Website', 'VIP Event', 'Doctor Referral', 'NA', 'Other'};
		System.AssertEquals(expected_list, Utilities.picklist_values('Account', 'AccountSource'));
	}

}