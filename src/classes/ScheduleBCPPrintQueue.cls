/*
05/14/2018  CC  Inital commit
05/31/2018  CC  Changed the wait time from 5 days to 24 hour after the lead record has been modified
*/

global class ScheduleBCPPrintQueue implements Schedulable {
    static final String poBoxStatus = 'PO Box';
    static final String notCheckedStatus = 'Not Checked';
    static final String insufficientInformationStatus = 'Insufficient Information';
    static final Integer startDateRange = -2;
    static final Integer endDateRange = -1;
    static String bcpBatchForm = 'BCP Letter';
    static String pendingStatus = 'Pending';
    global void execute(SchedulableContext sc) {
        System.debug('ScheduleBCPPrintQueue Started');
        System.debug('Looking for leads that have been pre_screen between ' + Date.today().addDays(startDateRange) + ' and ' + Date.today().addDays(endDateRange));
        List<lead> leads = new List<lead>();
        Util_TriggerContext.alteralreadyprocessed(true);
        leads = [SELECT Id, BCP_DVD_Packet_Sent__c 
                    FROM lead
                    WHERE
                        Pre_Screen__c != :poBoxStatus
                        AND Pre_Screen__c != :notCheckedStatus
                        AND Pre_Screen__c != :insufficientInformationStatus
                        AND Pre_Screen__c != null
                        AND DateTime_Consult_Scheduled__c = null
                        AND ((LastModifiedDate >= :Date.today().addDays(startDateRange)
                        AND LastModifiedDate < :Date.today().addDays(endDateRange)) OR (
                        Pre_Screen_Time__c >= :Date.today().addDays(startDateRange)
                        AND Pre_Screen_Time__c < :Date.today().addDays(endDateRange)))
                        AND BCP_DVD_Packet_Sent__c = false
                        AND Welcome_Packet_Sent__c = false
                        AND Id Not In (SELECT Lead_Id__c 
										FROM Awaiting_Bulk_Print__c 
										WHERE Batch_Form__c = :bcpBatchForm
											AND Status__c = :pendingStatus)];
        Set<Id> leadIds = (new Map<Id,SObject>(leads)).keySet();
        System.debug(leadIds.size() + ' leads record found');
        LeadBulkPrintPendingService.InsertBulkPrintRecords(leadIds, bcpBatchForm, pendingStatus);
        System.debug('ScheduleBCPPrintQueue Finished');
    }
}