/*
2017-04-03 Alon Waisman
ctrl_GP_Fee_view_and_update 97%
*/

@isTest
private class test_GP_Fee_view_and_update {

	private static void init() {
		Center_Information__c center = new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 30, latlong__Latitude__s = 30);
		insert center;

		insert new GP_Fee__c[]{new GP_Fee__c(Center_Information__c = center.ID, GP_Service__c = 1, Arch_Count__c = 1, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 10, Zirconia__c = 2),
								new GP_Fee__c(Center_Information__c = center.ID, GP_Service__c = 2, Arch_Count__c = 1, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 10, Zirconia__c = 2),
								new GP_Fee__c(Center_Information__c = center.ID, GP_Service__c = 3, Arch_Count__c = 1, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 10, Zirconia__c = 2),
								new GP_Fee__c(Center_Information__c = center.ID, GP_Service__c = 1, Arch_Count__c = 2, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 10, Zirconia__c = 2),
								new GP_Fee__c(Center_Information__c = center.ID, GP_Service__c = 2, Arch_Count__c = 2, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 10, Zirconia__c = 2),
								new GP_Fee__c(Center_Information__c = center.ID, GP_Service__c = 3, Arch_Count__c = 2, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 10, Zirconia__c = 2)
		};
	}

	@isTest static void test_it_gets_all_fee_records_and_can_update_them() {
		init();

		ctrl_GP_Fee_view_and_update controller = new ctrl_GP_Fee_view_and_update();
		controller.getcenter_options();
		controller.center_ID = [SELECT ID FROM Center_Information__c WHERE Name = 'Test Center'].ID;

		Test.StartTest();
			controller.retrieve_center_gp_fee_records();
			controller.single_service1.Titanium__c = 0;
			controller.single_service2.Titanium__c = 1;
			controller.single_service3.Titanium__c = 2;
			controller.double_service1.Titanium__c = 3;
			controller.double_service2.Titanium__c = 4;
			controller.double_service3.Titanium__c = 5;
			controller.save();
		Test.StopTest();


		GP_Fee__c[] gp_fees = [SELECT ID, Center_Information__c, Arch_Count__c, GP_Service__c, Phase_1__c, Phase_2_Titanium__c, Phase_2_Zirconia__c, Titanium__c, Zirconia__c FROM GP_Fee__c WHERE Center_Information__c = :controller.center_ID ORDER BY Titanium__c];

		system.assertEquals(6, gp_fees.size());
		for (GP_Fee__c gp_fee : gp_fees) {
			system.assertEquals(2, gp_fee.Zirconia__c);
		}
		for (Integer i = 0; i <= 5; i++) {
			system.assertEquals(i, gp_fees[i].Titanium__c);
		}
	}

}