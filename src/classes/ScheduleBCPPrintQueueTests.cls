/*
05/14/2018  CC  Inital commit
05/31/2018	CC	Changed test from waiting time of 5 days to 24 hours
*/

@isTest
private class ScheduleBCPPrintQueueTests {
	static Lead lead;
	static Awaiting_Bulk_Print__c bulkPrint;
	
	private static Lead createLead(Integer hoursPassed, Integer counter) {
		//Create lead for testing 
		lead = TestDataFactory.CreateTestLead();
		lead.BCP_DVD_Packet_Sent__c = false;
		lead.Street = '1234 Main St';
		lead.City = 'Denver';
		lead.State = 'CO';
		lead.PostalCode = '80111';
		lead.Warranty_ID__c = 'BA8D6569-9208-4' + counter;
		lead.Pre_Screen__c = 'Green';
        lead.Pre_Screen_Time__c = datetime.now().addDays(hoursPassed).addHours(-6);
		return lead;
	}

  	private static Integer ReturnAwaitingBulkPrintCount() {
  		return database.countQuery('select count() from Awaiting_Bulk_Print__c');
  	}

  	testMethod static void TestScheduleJobCreatedRecordsLeadsUpdatedFiveDaysBefore(){
		  System.debug('TestScheduleJobCreatedRecordsLeadsUpdatedFiveDaysBefore');
		Test.startTest();
		Integer counter = 0;
		Util_TriggerContext.alteralreadyprocessed(true);
		List<Lead> leads = new List<Lead>();
		while(counter < 100) {
			leads.add(createLead(-2, counter));
			counter = counter + 1;
		}
		insert leads;
		System.debug(leads);
		ScheduleBCPPrintQueue printQueue = new ScheduleBCPPrintQueue();
		printQueue.execute(null);
		//Our mock lead should trigger an awakiting_bulk_print to be inserted
		System.debug('Print queue: ' + ReturnAwaitingBulkPrintCount());
		System.assert(ReturnAwaitingBulkPrintCount() == 100);
		Test.stopTest();    
	}

  	testMethod static void TestScheduleJobSetBCPSentTrueLeadUpdatedFiveDaysBefore(){
		Test.startTest();
		insert createLead(-2, 1);
		ScheduleBCPPrintQueue printQueue = new ScheduleBCPPrintQueue();
		printQueue.execute(null);
		//Our mock lead should trigger an awakiting_bulk_print to be inserted
		System.debug('Print queue: ' + ReturnAwaitingBulkPrintCount());
		lead = [SELECT BCP_DVD_Packet_Sent__c
				FROM Lead
				Where Id = :lead.id];
        System.debug(lead);
		System.assert(lead.BCP_DVD_Packet_Sent__c == true);
		Test.stopTest();    
	}	

  	testMethod static void TestScheduleJobDoesNotCreatedDupRecord(){
		Test.startTest();
		insert createLead(-2, 1);	
		Awaiting_Bulk_Print__c bulkQueue = new Awaiting_Bulk_Print__c();
		bulkQueue.Batch_Form__c = 'BCP Letter';
		bulkQueue.Lead_Id__c = lead.Id;
		bulkQueue.Submitted_By__c = Userinfo.getUserId();
		bulkQueue.Status__c = 'Pending';
		insert bulkQueue;
		ScheduleBCPPrintQueue printQueue = new ScheduleBCPPrintQueue();
		printQueue.execute(null);
		System.assert(ReturnAwaitingBulkPrintCount() == 1);
		Test.stopTest();    
	}

  	testMethod static void TestScheduleJobDoNotCreatedRecordLeadUpdatedTwoDaysBefore(){
		Test.startTest();
		insert createLead(-48, 1);
		ScheduleBCPPrintQueue printQueue = new ScheduleBCPPrintQueue();
		printQueue.execute(null);
		//Our mock lead should trigger an awakiting_bulk_print to be inserted
		System.assert(ReturnAwaitingBulkPrintCount() == 0);
		Test.stopTest();    
	}
}