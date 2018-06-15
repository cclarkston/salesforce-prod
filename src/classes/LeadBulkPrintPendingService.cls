public without sharing class LeadBulkPrintPendingService {
    public static Set<Id> AwaitingBulkPrintExists(Set<Id> leadIds, String batchForm, String status) {
		List<Awaiting_Bulk_Print__c> bulkPrints = [	SELECT 	Lead_Id__c 
														FROM Awaiting_Bulk_Print__c 
														WHERE Batch_Form__c = :batchForm
															AND Lead_Id__c in :leadIds
															AND Status__c = :status];
		leadIds = new Set<Id>();
		for(Awaiting_Bulk_Print__c bulkPrint : bulkPrints ) {
			leadIds.add(bulkPrint.Lead_Id__c);
		}
		return leadIds;
	}
   
  	public static void InsertBulkPrintRecords(Set<Id> leads, String batchForm, String status) {
		List<Awaiting_Bulk_Print__c> bulkPrints = new List<Awaiting_Bulk_Print__c>();
		List<Task> tasks = new List<Task>();
		Set<Id> bulkPrintsExist = AwaitingBulkPrintExists(leads, batchForm, status);
		for(Id lead : leads) {
			if(!bulkPrintsExist.contains(lead)){
				bulkPrints.add(new Awaiting_Bulk_Print__c (Batch_Form__c = batchForm, Lead_Id__c = lead, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = status));
				tasks.add(new Task(WhoId = lead, OwnerId = Userinfo.getUserId(), Subject = batchForm, Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed'));
			}
		} 
		System.debug('Inserting: ' + tasks.size() + ' tasks');
		insert tasks;
		System.debug('Inserting: ' + bulkPrints.size() + ' bulkPrints');
		insert bulkPrints;
		//Update BCP_DVD_Packet_Sent__c for leads
		List<Lead> updateLeads = [SELECT BCP_DVD_Packet_Sent__c , Id
							FROM Lead
							WHERE Id in :leads];
							
		for(Lead lead : updateLeads ) {
			lead.BCP_DVD_Packet_Sent__c = true;
		}					
		update updateLeads;
	}
}