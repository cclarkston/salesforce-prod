@isTest
private class TestCtrlPrescreenColor {
  static Lead lead;
  static PageReference pageReference;
  static CtrlPrescreenColor extension;

  @testSetup static void setup() {
    insert new Lead(
      FirstName = 'Test',
      LastName = 'Patient',
      Street = '123 Main St',
      City = 'Denver',
      State = 'CO',
      PostalCode = '80111',
      Prospect_All_Score__c = '-4.52596639883',
      Prospect_All_Tier__c = 'Tier H'
    );
  }

  private static void init() {
    selectLead();

    pageReference = Page.PreScreenPage;
    pageReference.getParameters().put('id', lead.Id);
    Test.setCurrentPage(pageReference);

    ApexPages.StandardController controller =
                                        new ApexPages.standardController(lead);
    extension = new CtrlPrescreenColor(controller);
  }

  private static void selectLead() {
    lead = [SELECT Id, Pre_Screen__c, LeadScore__c
            FROM Lead
            LIMIT 1
          ];
  }

  static TestMethod void testAssignsColor() {
    selectLead();
    lead.Pre_Screen__c = 'Red';
    update lead;

    init();

    System.assertEquals('Red', lead.Pre_Screen__c);
    System.assertEquals('Red', lead.LeadScore__c);
    System.assertEquals('red', extension.color);
  }

  static TestMethod void testAssignsPoBox() {
    lead = [SELECT Id, Pre_Screen__c, LeadScore__c
            FROM Lead
            LIMIT 1
          ];
    lead.Pre_Screen__c = 'PO Box';
    update lead;

    init();

    System.assertEquals('PO Box', lead.LeadScore__c);
    System.assertEquals('purple', extension.color);
  }

  static TestMethod void testShowPrescreenButton() {
    selectLead();

    lead.StrikeForce1__USAddress_Address_Status__c = 'Verified';
    update lead;

    pageReference = Page.PreScreenPage;
    pageReference.getParameters().put('id', lead.Id);
    Test.setCurrentPage(pageReference);

    ApexPages.StandardController controller =
                                        new ApexPages.standardController(lead);
    extension = new CtrlPrescreenColor(controller);
    Boolean result = extension.showPrescreenButton();

    System.assert(result);
  }

  static TestMethod void testUpdateLeadscore() {
    selectLead();
    lead.Prospect_All_Score__c = '-1.4';
    lead.Prospect_All_Tier__c = '2';
    lead.Pre_Screen__c = 'Green';
    update lead;
    init();
    System.assertEquals('Green', extension.leadScore);

    lead.Pre_Screen__c = 'Red';
    update lead;
    extension.updateLeadscore();
    System.assertEquals('Red', extension.leadScore);
  }
}