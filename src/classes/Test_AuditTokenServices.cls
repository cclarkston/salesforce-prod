/*
6/1/16
Alon Waisman
Classes:
  AuditTokenServices - 100%
*/

@isTest
private class Test_AuditTokenServices {

	@isTest static void test_method_one() {
		Audit_Token__c token = new Audit_Token__c();
		token.Extend_Pending_Cancel__c 	= Date.newInstance(2000, 01, 01);
		token.Notes__c 					= 'test notes';
		insert token;

		Audit_Token__c token_from_db = [SELECT ID, Extend_Pending_Cancel__c, Notes__c FROM Audit_Token__c LIMIT 1];
		system.assert(token_from_db.Extend_Pending_Cancel__c != null);
		system.assertEquals('test notes', token_from_db.Notes__c);
		Test.startTest();
			String result = AuditTokenServices.clear_token(token.id, 'Test', 'User');
			Audit_Token__c cleared_token = [SELECT ID, Extend_Pending_Cancel__c, Notes__c FROM Audit_Token__c LIMIT 1];
			system.assert(cleared_token.Extend_Pending_Cancel__c == null);
			system.assert(cleared_token.Notes__c.contains('manually cleared'));
			system.assertEquals('Token cleared!', result);
		Test.stopTest();
	}

}