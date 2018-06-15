// Test for Invocable_CopyPartToCenterParts class
// the class automatically creates a Center Part when a master part is created
// and was called by a Process Builder
// The Process Builder has been disabled until more centers start selling parts
// The test has been disabled by comments

@isTest
private class Test_Invocable_Copy_Part_to_Centers {

	// static testMethod void test_it_creates_center_parts_for_each_new_part_in_centers_that_sell_parts() {
	// 	Market__c market 						  = new_market();
	// 	Center_Information__c test_center1 		  = new_center(market, 'Test Center 1', true);
	// 	Center_Information__c test_center2 		  = new_center(market, 'Test Center 2', true);
	// 	Center_Information__c center_no_sales	  = new_center(market, 'Test Center that does not sell parts', false);
	// 	System.AssertEquals(0, [SELECT COUNT() FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center1.id]);
	// 	System.AssertEquals(0, [SELECT COUNT() FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center2.id]);
	// 	System.AssertEquals(0, [SELECT COUNT() FROM ClearChoice_Center_Part__c WHERE Center__c = :center_no_sales.id]);
  //
	// 	ClearChoice_Part__c[] parts = new_part_list();
  //
	// 	ClearChoice_Center_Part__c[] center1_parts = 		 [SELECT Name, Part__c, Center__c, Price__c FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center1.id];
	// 	ClearChoice_Center_Part__c[] center2_parts = 		 [SELECT Name, Part__c, Center__c, Price__c FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center2.id];
	// 	ClearChoice_Center_Part__c[] center_no_sales_parts = [SELECT Name, Part__c, Center__c, Price__c FROM ClearChoice_Center_Part__c WHERE Center__c = :center_no_sales.id];
	// 	System.AssertEquals(parts.size(), center1_parts.size());
	// 	System.AssertEquals(parts.size(), center2_parts.size());
	// 	System.AssertEquals(0, 			  center_no_sales_parts.size());
  //
	// 	ClearChoice_Center_Part__c center_part = center1_parts[0];
	// 	ClearChoice_Part__c part = parts[0];
	// 	System.AssertEquals('Test Center 1 - ' + part.Name, center_part.Name);
	// 	System.AssertEquals(test_center1.id,				center_part.Center__c);
	// 	System.AssertEquals(parts[0].id,					center_part.Part__c);
	// 	System.AssertEquals(parts[0].Item_Price__c,			center_part.Price__c);
	// }
  //
	// static testMethod void test_it_does_not_create_center_parts_if_they_already_exist() {
	// 	Market__c market 						  = new_market();
	// 	Center_Information__c test_center1 		  = new_center(market, 'Test Center 1', true);
	// 	System.AssertEquals(0, [SELECT COUNT() FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center1.id]);
	// 	ClearChoice_Part__c[] parts = new_part_list();
	// 	System.AssertEquals(parts.size(), [SELECT count() FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center1.id]);
  //
	// 	ID[] part_ids = new ID[]{};
	// 	for (ClearChoice_Part__c part : parts) {part_ids.add(part.id);}
	// 	Invocable_CopyPartToCenterParts.add_new_parts_to_centers_selling_parts(part_ids);
  //
	// 	System.AssertEquals(parts.size(), [SELECT count() FROM ClearChoice_Center_Part__c WHERE Center__c = :test_center1.id]);
	// }
  //
	// 		private static Market__c new_market() {
	// 			Market__c m = new Market__c(Name = 'Test Market');
	// 			insert m;
	// 			return m;
	// 		}
	// 		private static Center_Information__c new_center(Market__c m, String name, Boolean sells_other) {
	// 			Center_Information__c center = new Center_Information__c(Name = name, Street_1__c = 'test', street_2__c = 'unit 103', city__c = 'Denver', state__c = 'Colorado',
	// 																		Tax_Rate__c = 7.3, directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
	// 																		cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
	// 																		doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = name,
	// 																		send_confirmation_email__c = true, confirmation_email_address__c = 'awaisman@clearchoice.com',
	// 																		Sells_Other_Products_Services__c = sells_other);
	// 			insert center;
	// 			return center;
	// 		}
	// 		private static ClearChoice_Part__c[] new_part_list() {
	// 			String product_rid = [SELECT ID FROM RecordType WHERE SobjectType = 'ClearChoice_Part__c' AND Name = 'Product'].id;
	// 			String service_rid = [SELECT ID FROM RecordType WHERE SobjectType = 'ClearChoice_Part__c' AND Name = 'Service'].id;
	// 			ClearChoice_Part__c[] parts = new ClearChoice_Part__c[] {new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Dental Product',    is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Dental Product',    upc__c = '666666666666', part_description__c = 'This is a test Dental product'),
	// 																	 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Product', is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Esthetics Product', upc__c = '777777777777', part_description__c = 'This is a test Esthetics product'),
	// 																	 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Service', is_taxable__c = false, recordtypeid = service_rid, name = 'Test Esthetics Service', upc__c = '888888888888', part_description__c = 'This is a test Esthetics service')};
	// 			insert parts;
	// 			return parts;
	// 		}

}