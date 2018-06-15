public with sharing class ctrl_GP_Fee_view_and_update {
	public GP_Fee__c single_service1 {get; set;}
	public GP_Fee__c single_service2 {get; set;}
	public GP_Fee__c single_service3 {get; set;}
	public GP_Fee__c double_service1 {get; set;}
	public GP_Fee__c double_service2 {get; set;}
	public GP_Fee__c double_service3 {get; set;}
	public ID        center_ID 			 {get; set;}
	private GP_Fee__c[] gp_fees;

	public ctrl_GP_Fee_view_and_update() {
	}

	public selectOption[] getcenter_options() {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', 'Select a center')};
		Center_Information__c[] centers = [SELECT ID, Name FROM Center_Information__c WHERE Active__c = TRUE ORDER BY Name];
		for (Center_Information__c center : centers) {options.add(new SelectOption(center.ID, center.Name));}
		return options;
	}

	public void retrieve_center_gp_fee_records() {
		initialize_values();
		GP_Fee__c[] fees = [SELECT ID, Center_Information__c, Arch_Count__c, GP_Service__c, Phase_1__c, Phase_2_Titanium__c, Phase_2_Zirconia__c, Titanium__c, Zirconia__c FROM GP_Fee__c WHERE Center_Information__c = :center_ID];
		for(GP_Fee__c fee : fees) {
			if        (fee.Arch_Count__c == 1) {
				if      (fee.GP_Service__c == 1) {single_service1 = fee;}
				else if (fee.GP_Service__c == 2) {single_service2 = fee;}
				else if (fee.GP_Service__c == 3) {single_service3 = fee;}
			} else if (fee.Arch_Count__c == 2) {
				if      (fee.GP_Service__c == 1) {double_service1 = fee;}
				else if (fee.GP_Service__c == 2) {double_service2 = fee;}
				else if (fee.GP_Service__c == 3) {double_service3 = fee;}
			}
		}

		gp_fees = new GP_Fee__c[]{single_service1, single_service2, single_service3, double_service1, double_service2, double_service3};
		for(GP_Fee__c gp_fee : gp_fees) {
			if (gp_fee.Center_Information__c == null) {gp_fee.Center_Information__c = center_ID;}
		}
	}

	public void initialize_values() {
		single_service1 = new GP_Fee__c(GP_Service__c = 1, Arch_Count__c = 1, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 0, Zirconia__c = 0);
		single_service2 = new GP_Fee__c(GP_Service__c = 2, Arch_Count__c = 1, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 0, Zirconia__c = 0);
		single_service3 = new GP_Fee__c(GP_Service__c = 3, Arch_Count__c = 1, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 0, Zirconia__c = 0);
		double_service1 = new GP_Fee__c(GP_Service__c = 1, Arch_Count__c = 2, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 0, Zirconia__c = 0);
		double_service2 = new GP_Fee__c(GP_Service__c = 2, Arch_Count__c = 2, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 0, Zirconia__c = 0);
		double_service3 = new GP_Fee__c(GP_Service__c = 3, Arch_Count__c = 2, Phase_1__c = 0, Phase_2_Titanium__c = 0, Phase_2_Zirconia__c = 0, Titanium__c = 0, Zirconia__c = 0);
	}

	public void save() {
		try                     {upsert gp_fees;}
		catch (Exception error) {ApexPages.addMessages(error);}
	}
}