@isTest
private class TestProspectIqService {
  static Lead lead;

  @testSetup static void setup() {
    Lead lead = new Lead(
      FirstName = 'Test',
      LastName = 'Patient',
      Street = '123 Main St',
      City = 'Denver',
      State = 'CO',
      PostalCode = '80111',
      StrikeForce1__USAddress_Address_Status__c = 'Verified'
    );

    insert lead;
  }

  static void init() {
    lead = [SELECT Id, FirstName, LastName, Street, City,
                   State, PostalCode, Pre_Screen__c,
                   Prescreen_Street_Name__c
            FROM Lead
            LIMIT 1
          ];
  }

  static TestMethod void testProspectIq() {
    init();
    Test.setMock(httpCalloutMock.class, new MockProspectIqServiceResponseGenerator());

    ProspectIqService.run(lead.Id);

    Lead updatedLead = [SELECT Prospect_All_Score__c, Prospect_All_Tier__c
            FROM Lead
            WHERE Id = :lead.Id
          ];

  }
}