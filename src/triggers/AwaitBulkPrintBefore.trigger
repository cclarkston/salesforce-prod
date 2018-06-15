trigger AwaitBulkPrintBefore on Awaiting_Bulk_Print__c (before insert) {
  static String pendingStatus = 'Pending';
  if(trigger.isInsert) {
    Map<String, Set<Id>> bulkPrintsExist = new Map<String, Set<Id>>();
    Map<String, Set<Id>> leadIdsByBatchForm = new Map<String, Set<Id>>();

    //Get any record to be inserted with the status of pending so that we can check if that
    //type of to record is already pendning for that lead
    for(Awaiting_Bulk_Print__c bulkPrint : Trigger.new) {
      if(bulkPrint.Status__c == pendingStatus) {
        if(!leadIdsByBatchForm.containsKey(bulkPrint.Batch_Form__c)) {
          Set<Id> newList = new Set<Id>();
          newList.add(bulkPrint.Lead_Id__c);
          leadIdsByBatchForm.put(bulkPrint.Batch_Form__c, newList);
        }
        else {
          Set<Id> thisList = leadIdsByBatchForm.get(bulkPrint.Batch_Form__c);
          thisList.add(bulkPrint.Lead_Id__c);
          leadIdsByBatchForm.remove(bulkPrint.Batch_Form__c);
          leadIdsByBatchForm.put(bulkPrint.Batch_Form__c, thisList);
        }
      }
    }   

    //Check if that type of bulk print already pending for each lead
    for(String batchForm : leadIdsByBatchForm.keySet()) {      
      Set<Id> existingIds = LeadBulkPrintPendingService.AwaitingBulkPrintExists(leadIdsByBatchForm.get(batchForm), batchForm, pendingStatus);
      if(existingIds.size() > 0) {
        bulkPrintsExist.put(batchForm, existingIds);
      }
    }

    for(Awaiting_Bulk_Print__c bulkPrint : Trigger.new) {
      if(bulkPrintsExist.containsKey(bulkPrint.Batch_Form__c) && bulkPrint.Status__c == 'Pending' && (bulkPrintsExist.get(bulkPrint.Batch_Form__c)).contains(bulkPrint.Lead_Id__c)){
        bulkPrint.addError('Pending record exist'); // prevent insert
      }
    }
  }
}