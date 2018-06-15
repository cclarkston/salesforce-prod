@isTest
private class AwaitBulkPrintBeforeTests {
	static Lead lead;
	static String bcpBatchForm = 'BCP Letter';
	static String welcomeBatchForm = 'Welcome Letter';

	private static void createLead() {
		//Create lead for testing 
		lead = new Lead();
		lead.lastName = 'Smith';
		lead.firstName = 'James';	
		lead.BCP_DVD_Packet_Sent__c = false;
		lead.Call_Center_Agent__c = UserInfo.getUserId();	
		insert lead;
	}

	private static Awaiting_Bulk_Print__c createAwaitBulkPrint(String batchForm) {
		Awaiting_Bulk_Print__c bulkQueue = new Awaiting_Bulk_Print__c();
		bulkQueue.Batch_Form__c = batchForm;
		bulkQueue.Lead_Id__c = lead.Id;
		bulkQueue.Submitted_By__c = Userinfo.getUserId();
		bulkQueue.Status__c = 'Pending';
		return bulkQueue;
	}
	
	@isTest static void TriggerPreventDupRecordTest() {
		Test.startTest();
		//Create lead for testing 
		createLead();
		//Create first AwaitingBulkPrint record
		insert createAwaitBulkPrint(bcpBatchForm);
		//Attempt to create another AwaitingBulkPrint record with the same properties
		try {
			insert createAwaitBulkPrint(bcpBatchForm);
		} catch(Exception error) {
			//Make sure the right error is thrown
			System.Assert(error.getMessage().contains('Pending record exist'));
		}
		//Select AwaitingBulkPrint records with the same properties should only return one record
		Integer bulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :bcpBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(bulkPrintCount == 1);
		Test.stopTest();  
	}

	@isTest static void TriggerCanCreteDifferentTypePendingRecoreds() {
		Test.startTest();
		//Create lead for testing 
		createLead();
		//Create AwaitingBulkPrint record for bcp
		insert createAwaitBulkPrint(bcpBatchForm);
		//Create first AwaitingBulkPrint record for welcome letter
		insert createAwaitBulkPrint(welcomeBatchForm);

		//Should have one bcp record
		Integer bcpBulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :bcpBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(bcpBulkPrintCount == 1);
		//Should have one welcome record
		Integer welcomeBulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :welcomeBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(welcomeBulkPrintCount == 1);
		Test.stopTest();  
	}		

	@isTest static void TriggerCanCreteDifferentTypePendingRecoredsAtTheSameTime() {
		Test.startTest();
		//Create lead for testing 
		createLead();
		
		List<Awaiting_Bulk_Print__c> bulkPrints = new List<Awaiting_Bulk_Print__c>();
		
		//Add different type of bulk print to set 
		bulkPrints.add(createAwaitBulkPrint(bcpBatchForm));
		bulkPrints.add(createAwaitBulkPrint(welcomeBatchForm));
		
		//Attempt to create bulkPrint records
		insert bulkPrints;

		//Should have one bcp record
		Integer bcpBulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :bcpBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(bcpBulkPrintCount == 1);
		//Should have one welcome record
		Integer welcomeBulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :welcomeBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(welcomeBulkPrintCount == 1);
		Test.stopTest();  
	}	

	@isTest static void TriggerCreatingDifferentTypesofRecordStillCatchDup() {
		Test.startTest();
		//Create lead for testing 
		createLead();
		//Create one welcome letter 
		insert createAwaitBulkPrint(welcomeBatchForm);
		
		List<Awaiting_Bulk_Print__c> bulkPrints = new List<Awaiting_Bulk_Print__c>();
		
		//Add different type of bulk print to set 
		bulkPrints.add(createAwaitBulkPrint(bcpBatchForm));
		bulkPrints.add(createAwaitBulkPrint(welcomeBatchForm));
		
		//Attempt to create bulkPrint records
		try {
			//Make sure AllOrNone is set to false
			Database.insert(bulkPrints, false);
		}  catch(Exception error) {
			//Make sure the right error is thrown
			System.Assert(error.getMessage().contains('Pending record exist'));
		}

		//Should have one bcp record
		Integer bcpBulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :bcpBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(bcpBulkPrintCount == 1);
		//Should have one welcome record
		Integer welcomeBulkPrintCount = [SELECT count() 
						FROM Awaiting_Bulk_Print__c
						WHERE Batch_Form__c = :welcomeBatchForm
							AND Lead_Id__c = :lead.Id
							AND Status__c = 'Pending'];
		System.assert(welcomeBulkPrintCount == 1);
		Test.stopTest();  
	}
}