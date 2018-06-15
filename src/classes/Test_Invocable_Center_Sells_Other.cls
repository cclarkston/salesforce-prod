/*
2016-07-05 Alon Waisman
Invocable_ActivateCenterSellsOther - 100%
*/

@isTest
private class Test_Invocable_Center_Sells_Other {

	static testMethod void test_it_can_create_center_parts_records_from_master_parts_table() {
		Market__c market 						  = new_market();
		Center_Information__c test_center 		  = new_center(market);
		ClearChoice_Part__c[] parts 			  = new_part_list();

		System.AssertEquals(0, [SELECT COUNT() FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center.id]);
		Invocable_ActivateCenterSellsOther.add_all_parts_to_center(new ID[]{test_center.id});

		ClearChoice_Center_Part__c[] center_parts = [SELECT Name, Part__c FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center.id];
		System.AssertEquals(parts.size(), center_parts.size());

		Invocable_ActivateCenterSellsOther.add_all_parts_to_center(new ID[]{test_center.id});
		center_parts = [SELECT Name, Part__c FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center.id];
		System.AssertEquals(parts.size(), center_parts.size());

		ClearChoice_Center_Part__c center_part = center_parts[0];
		ClearChoice_Part__c part = [SELECT Name FROM ClearChoice_Part__c WHERE ID = :center_part.Part__c];
		System.AssertEquals(center_part.Name, 'Test Center - ' + part.Name);
	}

			private static Market__c new_market() {
				Market__c m = new Market__c(Name = 'Test Market');
				insert m;
				return m;
			}
			private static Center_Information__c new_center(Market__c m) {
				Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', street_2__c = 'unit 103', city__c = 'Denver', state__c = 'Colorado',
																				Tax_Rate__c = 7.3, directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
																				cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
																				doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
																				send_confirmation_email__c = true, confirmation_email_address__c = 'awaisman@clearchoice.com');
				insert test_center;
				return test_center;
			}
			private static ClearChoice_Part__c[] new_part_list() {
				String product_rid = [Select id From RecordType where SobjectType = 'ClearChoice_Part__c' and Name = 'Product'].id;
				String service_rid = [Select id From RecordType where SobjectType = 'ClearChoice_Part__c' and Name = 'Service'].id;
				ClearChoice_Part__c[] parts = new ClearChoice_Part__c[] {new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Dental Product',    is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Dental Product',    upc__c = '666666666666', part_description__c = 'This is a test Dental product'),
																		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Product', is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Esthetics Product', upc__c = '777777777777', part_description__c = 'This is a test Esthetics product'),
																		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Service', is_taxable__c = false, recordtypeid = service_rid, name = 'Test Esthetics Service', upc__c = '888888888888', part_description__c = 'This is a test Esthetics service')};
				insert parts;
				return parts;
			}

}