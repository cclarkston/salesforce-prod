@isTest
private class LeadBeforeSetsPrescreenDefaultsTest {
  private static Lead lead;

  static void leadInsufficientInformation() {
    insert new Lead(
      FirstName = 'Test',
      LastName = 'Patient',
      Street = null,
      City = 'Denver',
      State = 'CO',
      PostalCode = '80111',
      Prospect_All_Score__c = '-4.52596639883',
      Prospect_All_Tier__c = 'Tier H'
    );
    selectLead();
  }

  static void leadPoBox() {
    insert new Lead(
      FirstName = 'Test',
      LastName = 'Patient',
      Street = 'PO Box 1234',
      City = 'Denver',
      State = 'CO',
      PostalCode = '80111',
      Prospect_All_Score__c = '-4.52596639883',
      Prospect_All_Tier__c = 'Tier H'
    );
    selectLead();
  }

  static void selectLead() {
    lead = [SELECT Id, Pre_Screen__c, LeadScore__c
            FROM Lead
            WHERE Name Like '%Test Patient'
          ];
  }

	@isTest
  static void setPrescreenToInsufficientInformationOnInsertTest() {
    // if any field required to prescreen is null set to Insufficient Information
		leadInsufficientInformation();
    System.assertEquals('Insufficient Information', lead.Pre_Screen__c);
	}

	// @isTest
  // static void setPrescreenToInsufficientInformationOnUpdateTest() {
  //   // if any field required to prescreen is null set to Insufficient Information
	// 	leadPoBox();
  //   System.assertEquals('PO Box', lead.Pre_Screen__c);
  //   lead.Street = null;
  //   update lead;
  //
  //   selectLead();
  //   System.assertEquals('Insufficient Information', lead.Pre_Screen__c);
	// }

  @isTest
  static void setPrescreenToPoBoxOnInsertTest() {
    // if the address contains the letters 'po box' set to 'PO Box'
		leadPoBox();
    System.assertEquals('PO Box', lead.Pre_Screen__c);
	}

  @isTest
  static void setPrescreenToPoBoxOnUpdateTest() {
    // if the address contains the letters 'po box' set to 'PO Box'
		leadInsufficientInformation();
    System.assertEquals('Insufficient Information', lead.Pre_Screen__c);
    lead.Street = 'PO Box 1234';
    update lead;

    selectLead();
    System.assertEquals('PO Box', lead.Pre_Screen__c);
	}
}