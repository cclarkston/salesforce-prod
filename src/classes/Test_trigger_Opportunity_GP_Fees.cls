@isTest

private class Test_trigger_Opportunity_GP_Fees {

	private static void init() {

		// GP Fee --> Center information(requires accountid) <-- Account <-- Opportunity(to get account to get center) <-- Treatment plan --> Treatment option

		Center_Information__c center = new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 30, latlong__Latitude__s = 30);
		insert center;

		String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
		Account account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = center.id, RecordTypeId = rid);
		insert account;

		Opportunity opportunity1 = new Opportunity(AccountID = account.id, Name = 'Opportunity 1', StageName = 'StageName Name', CloseDate = System.today());
		Opportunity opportunity2 = new Opportunity(AccountID = account.id, Name = 'Opportunity 2', StageName = 'StageName Name', CloseDate = System.today());
		Opportunity opportunity3 = new Opportunity(AccountID = account.id, Name = 'Opportunity 3', StageName = 'StageName Name', CloseDate = System.today());
		Opportunity opportunity4 = new Opportunity(AccountID = account.id, Name = 'Opportunity 4', StageName = 'StageName Name', CloseDate = System.today());
		insert new Opportunity[]{opportunity1, opportunity2, opportunity3, opportunity4};



		insert new GP_Fee__c[]{ new GP_Fee__c(Center_Information__c = center.id, Arch_Count__c = 1, gp_service__c = 1, phase_1__c = 1000, phase_2_titanium__c = 0,    phase_2_zirconia__c = 0,    titanium__c = 1000, zirconia__c = 1000),
														new GP_Fee__c(Center_Information__c = center.id, Arch_Count__c = 1, gp_service__c = 2, phase_1__c = 0,    phase_2_titanium__c = 2000, phase_2_zirconia__c = 2500, titanium__c = 2000, zirconia__c = 2500),
														new GP_Fee__c(Center_Information__c = center.id, Arch_Count__c = 1, gp_service__c = 3, phase_1__c = 0,    phase_2_titanium__c = 3000, phase_2_zirconia__c = 3500, titanium__c = 3000, zirconia__c = 3500),
														new GP_Fee__c(Center_Information__c = center.id, Arch_Count__c = 2, gp_service__c = 1, phase_1__c = 1000, phase_2_titanium__c = 0,    phase_2_zirconia__c = 0,    titanium__c = 1000, zirconia__c = 1000),
														new GP_Fee__c(Center_Information__c = center.id, Arch_Count__c = 2, gp_service__c = 2, phase_1__c = 0,    phase_2_titanium__c = 2333, phase_2_zirconia__c = 2666, titanium__c = 2333, zirconia__c = 2666),
														new GP_Fee__c(Center_Information__c = center.id, Arch_Count__c = 2, gp_service__c = 3, phase_1__c = 0,    phase_2_titanium__c = 3333, phase_2_zirconia__c = 3666, titanium__c = 3333, zirconia__c = 3666)};

		Treatment_Option__c treatment_option1 = new Treatment_Option__c(Start_Value__c = 1, Name = 'Test Titanium', upper_tag__c = 'AO4', lower_tag__c = 'None', category__c = 'Standard', treatment_grade__c = 'Better');
		Treatment_Option__c treatment_option2 = new Treatment_Option__c(Start_Value__c = 1, Name = 'Test Zirconia', upper_tag__c = 'Zirconia', lower_tag__c = 'Zirconia', category__c = 'Standard', treatment_grade__c = 'Best');
		Treatment_Option__c treatment_option3 = new Treatment_Option__c(Start_Value__c = 1, Name = 'Test Phase 1', upper_tag__c = 'Phased', lower_tag__c = 'None', category__c = 'Phased');
		Treatment_Option__c treatment_option4 = new Treatment_Option__c(Start_Value__c = 1, Name = 'Test Phase 2', upper_tag__c = 'Arch Upgrade', lower_tag__c = 'None', category__c = 'Arch Upgrade', treatment_grade__c = 'Best');
		insert new Treatment_Option__c[]{treatment_option1, treatment_option2, treatment_option3, treatment_option4};

		Treatment_Plan__c treatment_plan1 = new Treatment_Plan__c(Opportunity__c = opportunity1.id, Treatment_Option__c = treatment_option1.id);
		Treatment_Plan__c treatment_plan2 = new Treatment_Plan__c(Opportunity__c = opportunity2.id, Treatment_Option__c = treatment_option2.id);
		Treatment_Plan__c treatment_plan3 = new Treatment_Plan__c(Opportunity__c = opportunity3.id, Treatment_Option__c = treatment_option3.id);
		Treatment_Plan__c treatment_plan4 = new Treatment_Plan__c(Opportunity__c = opportunity4.id, Treatment_Option__c = treatment_option4.id);
		insert new Treatment_Plan__c[]{treatment_plan1, treatment_plan2, treatment_plan3, treatment_plan4};
	}

	@isTest static void test_gp_fees_change_as_expected_when_checkboxes_change_for_single_arch_titanium() {
		init();

		Opportunity before_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE name = 'Opportunity 1'];
		before_opportunity.GP_Service_1__c = true;
		before_opportunity.GP_Service_2__c = true;
		before_opportunity.GP_Service_3__c = true;

		Test.StartTest();
			update before_opportunity;
		Test.StopTest();

		Opportunity after_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE id = :before_opportunity.id];

		// Check that GP Fees update
		System.assertNotEquals(before_opportunity.GP_Fee_1__c, after_opportunity.GP_Fee_1__c);
		System.assertNotEquals(before_opportunity.GP_Fee_2__c, after_opportunity.GP_Fee_2__c);

		// Check that they're correct
		System.assertEquals(1000, after_opportunity.GP_Fee_1__c);
		System.assertEquals(5000, after_opportunity.GP_Fee_2__c);
	}

	@isTest static void test_gp_fees_are_set_correctly_for_double_arch_zirconia() {
		init();

		Opportunity before_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE name = 'Opportunity 2'];
		before_opportunity.GP_Service_1__c = true;
		before_opportunity.GP_Service_2__c = false;
		before_opportunity.GP_Service_3__c = true;

		Test.StartTest();
			update before_opportunity;
		Test.StopTest();

		Opportunity after_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE id = :before_opportunity.id];

		// Check that they're correct
		System.assertEquals(1000, after_opportunity.GP_Fee_1__c);
		System.assertEquals(3666, after_opportunity.GP_Fee_2__c);
	}

	@isTest static void test_gp_fees_are_set_correctly_for_phase_1() {
		init();

		Opportunity before_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE name = 'Opportunity 3'];
		before_opportunity.GP_Service_1__c = true;
		before_opportunity.GP_Service_2__c = true;
		before_opportunity.GP_Service_3__c = true;

		Test.StartTest();
			update before_opportunity;
		Test.StopTest();

		Opportunity after_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE id = :before_opportunity.id];

		// Check that they're correct
		System.assertEquals(1000, after_opportunity.GP_Fee_1__c);
		System.assertEquals(0, after_opportunity.GP_Fee_2__c);
	}

	@isTest static void test_gp_fees_are_set_correctly_for_phase_2() {
		init();

		Opportunity before_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE name = 'Opportunity 4'];
		before_opportunity.GP_Service_1__c = true;
		before_opportunity.GP_Service_2__c = true;
		before_opportunity.GP_Service_3__c = true;

		Test.StartTest();
			update before_opportunity;
		Test.StopTest();

		Opportunity after_opportunity = [SELECT ID, GP_Service_1__c, GP_Service_2__c, GP_Service_3__c, GP_Fee_1__c, GP_Fee_2__c FROM Opportunity WHERE id = :before_opportunity.id];

		// Check that they're correct
		System.assertEquals(0, after_opportunity.GP_Fee_1__c);
		System.assertEquals(6000, after_opportunity.GP_Fee_2__c);
	}

}