@isTest
private class test_sales_order {

  @testSetup
	static void setup() {
		User test_user 							  = new_user();
		Market__c market 						  = new_market();
		Center_Information__c test_center 		  = new_center(market);
		Consult_Rooms__c test_room 				  = new_consult_room(test_center);
		ClearChoice_Doctor__c cd  				  = new_doctor(test_center);
		ClearChoice_Part__c[] parts 			  = new_part_list();
		ClearChoice_Center_Part__c[] center_parts = new_center_part_list(parts, test_center);
		Private_Practice_Patient__c pp 			  = new_ppp(test_center);
		create_account(test_center, test_user);
	}

			private static User new_user() {
				Profile p = [select id from Profile where name = 'System Administrator'];
				User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
												alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
												timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
				insert my_test_user;
				return my_test_user;
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
			private static Consult_Rooms__c new_consult_room(Center_Information__c test_center) {
				Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Practice');
				insert test_room;
				return test_room;
			}
			private static ClearChoice_Doctor__c new_doctor(Center_Information__c test_center) {
				ClearChoice_Doctor__c cd  = new ClearChoice_Doctor__c(First_Name__c = 'First',Last_name__c = 'Last test', Active__c = true, Center_Information__c = test_center.id, Name = 'First Last Test');
				insert cd;
				return cd;
			}
			private static ClearChoice_Part__c[] new_part_list() {
				String product_rid = [Select id From RecordType where SobjectType = 'ClearChoice_Part__c' and Name = 'Product'].id;
				String service_rid = [Select id From RecordType where SobjectType = 'ClearChoice_Part__c' and Name = 'Service'].id;
				ClearChoice_Part__c[] parts = new ClearChoice_Part__c[] {new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Product', is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Product 1',         upc__c = '123456789012', part_description__c = 'this is a test product', Is_Active__c = true),
																		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Service', is_taxable__c = false, recordtypeid = service_rid, name = 'Test Service 1',         upc__c = '555555555555', part_description__c = 'this is a test service', Is_Active__c = true),
																		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Dental Product',    is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Dental Product',    upc__c = '666666666666', part_description__c = 'This is a test Dental product', Is_Active__c = true),
																		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Product', is_taxable__c = true,  recordtypeid = product_rid, name = 'Test Esthetics Product', upc__c = '777777777777', part_description__c = 'This is a test Esthetics product', Is_Active__c = true),
																 		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Service', is_taxable__c = false, recordtypeid = service_rid, name = 'Test Esthetics Service', upc__c = '888888888888', part_description__c = 'This is a test Esthetics service', Is_Active__c = true),
																 		 new ClearChoice_Part__c(Brand__c = 'None', Type__c = 'Esthetics Service', is_taxable__c = false, recordtypeid = service_rid, name = 'CC99999', upc__c = '888888888888', part_description__c = 'This is a test Esthetics service', Is_Active__c = true)};
				insert parts;
				return parts;
			}
			private static ClearChoice_Center_Part__c[] new_center_part_list(ClearChoice_Part__c[] parts, Center_Information__c center) {
				ClearChoice_Center_Part__c[] center_parts = new ClearChoice_Center_Part__c[]{new ClearChoice_Center_Part__c(Center__c = center.id, Part__c = parts[0].id, Price__c = 34.50, Cost__c = 12.35, Quantity__c = 24),
																							 new ClearChoice_Center_Part__c(Center__c = center.id, Part__c = parts[1].id, Price__c = 10000),
																							 new ClearChoice_Center_Part__c(Center__c = center.id, Part__c = parts[2].id, Price__c = 55.55, Cost__c = 10.00, Quantity__c = 4),
																							 new ClearChoice_Center_Part__c(Center__c = center.id, Part__c = parts[3].id, Price__c = 66.66, Cost__c = 20.00, Quantity__c = 8),
																							 new ClearChoice_Center_Part__c(Center__c = center.id, Part__c = parts[4].id, Price__c = 99.99),
																							 new ClearChoice_Center_Part__c(Center__c = center.id, Part__c = parts[5].id, Price__c = 0)};
				insert center_parts;
				return center_parts;
			}
			private static Private_Practice_Patient__c new_ppp(Center_Information__c test_center) {
				Private_Practice_Patient__c pp = new Private_Practice_Patient__c(center__c = test_center.id, first_name__c = 'test', last_name__c = 'patient', Practice_ID__c = 'x', street_address__c = '23125 E Testing Street, Unit 102', city__c = 'Denver', state__c = 'Colorado', postal_code__c = '12561');
				insert pp;
				return pp;
			}
			private static PageReference new_page() {
				PageReference pageref = new PageReference('/apex/sales_order');
				pageref.getParameters().put('action', 'New');
				Private_practice_Patient__c pp = [select id from Private_Practice_Patient__c limit 1];
				pageref.getParameters().put('ppid', pp.id);
				return pageref;
			}
			private static void create_account(Center_Information__c test_center, User test_user) {
				String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
				Account test_account = new Account(Consult_Result__c = '30 Day Pipeline', Center__c = test_center.id, RecordTypeId = rid, Language_Spoken__c = 'Spanish', ownerid = test_user.id,
													FirstName = 'Test', LastName = 'Account', Gender__c = 'Female', Date_of_Birth__c = Date.newInstance(1979, 2, 20), PersonMobilePhone = '7193321582', PersonEmail = 'test@testuser.com',
													BillingStreet = '123 Test St.', BillingCity = 'Test City', BillingState = 'Alabama', BillingPostalcode = '01234-1234', phone = '6031234567');
				insert test_account;
			}

	static testMethod void test_the_sales_order_has_the_correct_totals() {
		Center_Information__c center = [SELECT Tax_Rate__c FROM Center_Information__c WHERE Name = 'Test Center' LIMIT 1];
		PageReference page = new_page();
		Test.setCurrentPage(page);
		test.startTest();
			ctrl_sales_order controller = new ctrl_sales_order();
			controller.check_for_actions();

			// Check it gets the subtotal and tax correct for one taxable item
			Integer center_part1_quantity = 2;
			Integer center_part2_quantity = 1;
			Integer center_part3_quantity = 1;
			Decimal tax_rate = (center.Tax_Rate__c / 100);

			ClearChoice_Center_Part__c center_part1 = add_part(page, controller, 'Test Dental Product', center_part1_quantity);
			Decimal center_part1_subtotal = (center_part1.Price__c * center_part1_quantity);
			Decimal expected_subtotal = center_part1_subtotal;
			Decimal expected_tax = (center_part1_subtotal * tax_rate).setScale(2);
			System.AssertEquals(expected_subtotal, controller.sales_order.Subtotal__c);
			System.AssertEquals(expected_tax, controller.sales_order.Tax_Total__c.setScale(2));

			// Check it gets the subtotal and tax correct for two taxable items
			ClearChoice_Center_Part__c center_part2 = add_part(page, controller, 'Test Esthetics Product', center_part2_quantity);
			Decimal center_part2_subtotal = (center_part2.Price__c * center_part2_quantity);
			expected_subtotal = center_part1_subtotal + center_part2_subtotal;
			expected_tax = (center_part1_subtotal * tax_rate).setScale(2) + (center_part2_subtotal * tax_rate).setScale(2);
			System.AssertEquals(expected_subtotal, controller.sales_order.Subtotal__c);
			System.AssertEquals(expected_tax, controller.sales_order.Tax_Total__c.setScale(2));

			// Check it gets the subtotal and tax correct for multiple items, one of which is not taxable
			ClearChoice_Center_Part__c center_part3 = add_part(page, controller, 'Test Esthetics Service', center_part3_quantity);
			Decimal center_part3_subtotal = (center_part3.Price__c * center_part3_quantity);
			expected_subtotal = center_part1_subtotal + center_part2_subtotal + center_part3_subtotal;
			expected_tax = (center_part1_subtotal * tax_rate).setScale(2) + (center_part2_subtotal * tax_rate).setScale(2);
			System.AssertEquals(expected_subtotal, controller.sales_order.Subtotal__c);
			System.AssertEquals(expected_tax, controller.sales_order.Tax_Total__c.setScale(2));
		test.stopTest();
	}

			private static ClearChoice_Center_Part__c add_part(PageReference page, ctrl_sales_order controller, String part_name, Integer quantity) {
				ClearChoice_Center_Part__c center_part = [SELECT Price__c FROM ClearChoice_Center_Part__c WHERE Part__r.Name = :part_name];
				page.getParameters().put('pid', center_part.id);
				controller.add_so_part();
				change_quantity(page, controller, center_part, quantity);
				return center_part;
			}
			private static void change_quantity(PageReference page, ctrl_sales_order controller, ClearChoice_Center_Part__c center_part, Integer quantity) {
				Sales_Order_Line_Item__c line_item = line_item(center_part);
				page.getParameters().put('slid', line_item.id);
				page.getParameters().put('qty', String.valueOf(quantity));
				controller.qty_change();
			}
			private static Sales_Order_Line_Item__c line_item(ClearChoice_Center_Part__c center_part) {
				return [SELECT ID, Quantity__c FROM Sales_Order_Line_Item__c WHERE ClearChoice_Center_Part__c = :center_part.id];
			}

	static testMethod void test_the_payment_categories_are_properly_assigned_in_a_complicated_transaction() {
		// init();
		// Center_Information__c center = [SELECT Tax_Rate__c FROM Center_Information__c WHERE Name = 'Test Center' LIMIT 1];
		// PageReference page = new_page();
		// Test.setCurrentPage(page);
		// test.startTest();
		// 	ctrl_sales_order controller = new ctrl_sales_order();
		// 	controller.check_for_actions();
		// 	ClearChoice_Center_Part__c center_part1 = add_part(page, controller, 'Test Dental Product', 1);
		// 	ClearChoice_Center_Part__c center_part2 = add_part(page, controller, 'Test Esthetics Product', 2);
		// 	ClearChoice_Center_Part__c center_part3 = add_part(page, controller, 'Test Esthetics Service', 1);
    //
		// 	add_payment(controller,  35.00,  0, 'Cash', 	  'Collected');
		// 	add_payment(controller,  20.00,  0, 'Cash', 	  'Refund');
		// 	add_payment(controller,  10.00,  0, 'Cash', 	  'Refund');
		// 	add_payment(controller, 200.13, 20, 'CareCredit', 'Collected');
		// 	add_payment(controller,  97.52,  0, 'Cash', 	  'Collected');
    //
    //
		// 	controller.invoice_sales_order();
		// 	Private_Practice_Payment__c[] payment_list = controller.payment_list;
    //
		// 	//Payment Amount, Finance Fee, Status, Tax, Dental Product, Esthetics Product, Esthetics Service
		// 	check_payment_categories(payment_list[0],  35.00,  0, 'Collected', 13.78751, 21.21249,      0,     0);
		// 	check_payment_categories(payment_list[1],  20.00,  0,    'Refund',     0,    20,      0,     0);
		// 	check_payment_categories(payment_list[2],  10.00,  0,    'Refund',  8.79,  1.21,      0,     0);
		// 	check_payment_categories(payment_list[3], 200.13, 20, 'Collected',  8.79, 55.55, 133.32,  2.47);
		// 	check_payment_categories(payment_list[4],  97.52,  0, 'Collected',     0,     0,      0, 97.52);
		// test.stopTest();
	}

			private static void add_payment(ctrl_sales_order controller, Decimal amount, Decimal finance_fee, String type, String status) {
				controller.new_payment.Payment_Amount__c = amount;
				controller.new_payment.Finance_Fee__c	 = finance_fee;
				controller.new_payment.Payment_Type__c   = type;
				controller.new_payment.Payment_Status__c = status;
				controller.add_payment();
			}

			private static void check_payment_categories(Private_Practice_Payment__c payment, Decimal payment_amount, Decimal finance_fee, String status, Decimal tax, Decimal dental_product, Decimal esthetic_product, Decimal esthetic_service) {
				System.AssertEquals(payment_amount,   payment.Payment_Amount__c);
				System.AssertEquals(finance_fee,      payment.Finance_Fee__c);
				System.AssertEquals(status,			  payment.Payment_Status__c);
				System.AssertEquals(tax.setScale(2),			  payment.Tax_Amount__c.setScale(2));
				System.AssertEquals(dental_product.setScale(2),   payment.Dental_Product_Amount__c.setScale(2));
				System.AssertEquals(esthetic_product, payment.Esthetics_Product_Amount__c);
				System.AssertEquals(esthetic_service.setScale(2), payment.Esthetics_Service_Amount__c.setScale(2));
			}

	static testMethod void test_sales_order() {
		test.starttest();
			PageReference pageref = new PageReference('/apex/sales_order');
			pageRef.getParameters().put('action', 'New');
			Private_practice_Patient__c pp = [select id from Private_Practice_Patient__c limit 1];
			pageRef.getParameters().put('ppid', pp.id);
			Test.setCurrentPage(pageRef);
			ctrl_sales_order controller = new ctrl_sales_order();
			controller.check_for_actions();
			controller.getcenter_address();
			controller.getcenter_name();
			controller.getpatient_address();
			controller.close_modal();

			List<SelectOption> option_list = controller.getbrandlist();
			option_list = controller.getPtypelist();
			option_list = controller.getvalid_payments();
			option_list = controller.getvalid_payment_status();
			controller.upc_scan();
			ClearChoice_Center_Part__c cp = [SELECT ID, Part__r.UPC__c FROM ClearChoice_Center_Part__c WHERE Part__r.Name = 'Test Product 1'];
			pageRef.getParameters().put('upc', cp.Part__r.UPC__c);
			Test.setCurrentPage(pageRef);
			controller.upc_scan();
			pageRef.getParameters().put('upc', 'No Match');
			Test.setCurrentPage(pageRef);
			controller.upc_scan();
			controller.add_so_part();

			cp = [SELECT ID FROM ClearChoice_Center_Part__c WHERE Part__r.Name = 'Test Product 1'];
			pageRef.getParameters().put('pid', cp.id);
			Test.setCurrentPage(pageRef);
			controller.add_so_part();

			controller.display_part_search();
			controller.searched_part.type__c = 'Product';
			controller.searched_part.name = 'Test';
			controller.searched_part.part_description__c = 'test';
			controller.searched_part.brand__c = 'None';
			controller.searched_part.upc__c = '123456789012';
			controller.getpart_search_matches();

			controller.display_note_form();
			controller.add_new_note();
			controller.sol.line_note__c = 'testing notes';
			controller.add_new_note();
			Sales_Order_Line_Item__c sl = [select id from Sales_Order_Line_Item__c where line_note__c != null limit 1];
			controller.delete_note();
			pageRef.getParameters().put('slid', sl.id);
			Test.setCurrentPage(pageRef);
			controller.delete_note();


			controller.getitem_list();
			sl = [select id from Sales_Order_Line_Item__c limit 1];
			pageRef.getParameters().put('slid', sl.id);
			pageRef.getParameters().put('qty', '2');
			pageRef.getParameters().put('price', '20.50');
			Test.setCurrentPage(pageRef);
			controller.qty_change();
			controller.price_change();

			pageRef.getParameters().put('qty', '999999');
			pageRef.getParameters().put('price', '-20.50');
			Test.setCurrentPage(pageRef);
			controller.qty_change();
			controller.price_change();

			controller.getorder_total();

			pageRef.getParameters().put('qty', '0');
			Test.setCurrentPage(pageRef);
			controller.qty_change();

			controller.calculate_so_totals();
			controller.print_mode();
			controller.edit_mode();

			controller.display_payment_form();
			controller.new_payment.payment_amount__c = 20.00;
			controller.new_payment.payment_type__c = 'Cash';
			controller.new_payment.payment_status__c = 'Collected';
			controller.add_payment();

			controller.display_payment_form();
			controller.new_payment.payment_amount__c = 5.00;
			controller.new_payment.payment_type__c = 'Cash';
			controller.new_payment.payment_status__c = 'Refunded';
			controller.add_payment();

			controller.getamount_paid();
			controller.oos_save();

			controller.update_payment_list();
			controller.refresh_payment_list();
			controller.getpayment_details();
			controller.invoice_sales_order();

			Account a = [select id from Account limit 1];
			pageRef.getParameters().put('acid', a.id);
			pageRef.getParameters().put('ppid', null);
			Test.setCurrentPage(pageRef);
			controller = new ctrl_sales_order();
			controller.check_for_actions();
			controller.getcenter_name();
			controller.getcenter_address();
			controller.getpatient_address();

			Sales_Order__c so = [select id from Sales_Order__c limit 1];
			pageRef.getParameters().put('so_num', so.id);
			Test.setCurrentPage(pageRef);
			controller = new ctrl_sales_order();
		test.stoptest();
	}

  // tests for Series_Balance__c

  private static String part_name;
  private static Decimal amount;
  private static Center_Information__c center;
  private static PageReference page;
  private static ctrl_sales_order controller;
  private static Sales_Order__c sales_order;
  private static Id patient_id;
  private static Private_Practice_Patient__c patient;
  private static ClearChoice_Center_Part__c center_part;

  static void initSeriesBalanceTest() {
    part_name = 'CC99999';
    amount = 500;
    center = getCenter();
    page = new_page();
    Test.setCurrentPage(page);
    controller = new ctrl_sales_order();
    controller.check_for_actions();
    sales_order = controller.sales_order;
    patient_id = sales_order.Private_Practice_Patient__r.Id;
    patient = getPatient();
    center_part = add_part_with_amount(page, controller, part_name, 1, amount);
  }

  static testMethod void itShouldAddSeriesPrepaidToPatientSeriesBalance() {
    initSeriesBalanceTest();
    System.assertEquals(null, patient.Series_Balance__c);

    patient = getPatient();
    System.assertEquals(500, patient.Series_Balance__c);
  }

  static testMethod void itShouldSubtractSeriesCreditFromPatientSeriesBalance() {
    initSeriesBalanceTest();
    System.assertEquals(null, patient.Series_Balance__c);

    patient = getPatient();
    System.assertEquals(500, patient.Series_Balance__c);

    add_payment(controller,  100,  0, 'Series Credit', 'Collected');
    patient = getPatient();
    System.assertEquals(400, patient.Series_Balance__c);
  }

  static testMethod void itShouldNotSubtractSeriesCreditFromPatientSeriesBalanceIfFundsNotAvailable() {
    String expected = 'Series Balance insufficient to fund Series Credit. Series Balance is $500';
    initSeriesBalanceTest();
    System.assertEquals(null, patient.Series_Balance__c);

    patient = getPatient();
    System.assertEquals(500, patient.Series_Balance__c);

    add_payment(controller, 600, 0, 'Series Credit', 'Collected');
    patient = getPatient();
    System.assertEquals(500, patient.Series_Balance__c);

    ApexPages.CurrentPage().getParameters().put('hasError','true');

    List<Apexpages.Message> messages = ApexPages.getMessages();
    Boolean hasErrorMessage = false;

    for(Apexpages.Message message : messages){
      System.debug('crash: ' + message);
      System.debug('crash: ' + expected);
        if (message.getDetail().contains(expected)){
          hasErrorMessage = true;
        }
    }
    System.assert(hasErrorMessage);
  }

  // Series_Balance__c test helper methods
  private static Center_Information__c getCenter() {
    return [SELECT Tax_Rate__c
            FROM Center_Information__c
            WHERE Name = 'Test Center'
            LIMIT 1
          ];
  }

  private static Private_Practice_Patient__c getPatient() {
    return [SELECT Series_Balance__c
            FROM Private_Practice_Patient__c
            WHERE Id = :patient_id
          ];

  }

  private static ClearChoice_Center_Part__c add_part_with_amount(PageReference page, ctrl_sales_order controller, String part_name, Integer quantity, Decimal amount) {
    ClearChoice_Center_Part__c center_part = [SELECT Price__c
                                              FROM ClearChoice_Center_Part__c
                                              WHERE Part__r.Name = :part_name
                                            ];

    page.getParameters().put('pid', center_part.id);
    controller.add_so_part();
    change_amount(page, controller, center_part, quantity, amount);
    return center_part;
  }

  private static void change_amount(PageReference page, ctrl_sales_order controller, ClearChoice_Center_Part__c center_part, Integer quantity, Decimal amount) {
    Sales_Order_Line_Item__c line_item = line_item(center_part);
    page.getParameters().put('slid', line_item.id);
    page.getParameters().put('price', String.valueOf(amount));
    controller.price_change();
  }
}