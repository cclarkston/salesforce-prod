@isTest
private class TestTempPasswordGenerator {

	static testMethod void testGenerateTempPassword() {
		Account account = new Account(FirstName = 'Test', LastName = 'User',
																	BillingStreet = '123 Main St', BillingCity = 'Denver',
																	BillingState = 'CO', BillingPostalCode = '80001',
																	BillingCountry = 'United States',
																	Phone = '1234657891', PersonMobilePhone = null,
																	PersonEmail = 'testuser@test.com',
																	Date_of_Birth__c = (System.today() - 20000),
																	Prostho_Exam_Date__c = (System.today() + 1),
																	Temp_Password__c = '1234');

		insert account;

		Test.StartTest();
			TempPasswordGenerator.generateTempPassword(account.Id);
		Test.StopTest();

		Account[] updatedAccount = [SELECT Id, Temp_Password__c FROM Account WHERE Id = :account.Id];

		System.assertEquals(updatedAccount[0].Temp_Password__c.length(), 5);
	}

	static testMethod void testGenerateTempPasswordFails() {
		Test.StartTest();
			TempPasswordGenerator.generateTempPassword(null);
			Integer invocations = Limits.getEmailInvocations();
		Test.StopTest();

		System.assertEquals(1, invocations, 'An email should be sent.');
	}
}