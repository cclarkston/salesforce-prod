global class CenterSupportRequestSubmitReminder implements Schedulable {
	
	global void execute(SchedulableContext context) {
		Datetime target = Datetime.now().addDays(-1);

		Center_Support_Request__c[] requests = [SELECT Id, CreatedBy.FirstName, CreatedBy.Email, CreatedById,
		                                        Submit_Reminder_Count__c,
		                                        CreatedDate
		                                        FROM Center_Support_Request__c
		                                        WHERE Submitted_for_Approval__c = false
		                                        AND Status__c = 'Open'
		                                        AND CreatedDate <= :target]; //AND CreatedDate < :target];

		if(requests.size() != 0) {
			for(Center_Support_Request__c request : requests) {
				request.Submit_Reminder_Count__c += 1;
			}

			try {
				CenterSupportRequestNotification.sendSubmitReminder(requests);
			}
			catch (DmlException error) {
				System.debug('The following exception has occurred: ' + error.getMessage());
			}
			try {
				update requests;
			}
			catch(DmlException error) {
				System.debug('The following exception has occurred: ' + error.getMessage());
			}
		}
	}
}

// Executed in the console to initialize CronTrigger:

// CenterSupportRequestSubmitReminder centerSupportRequestSubmitReminder = new CenterSupportRequestSubmitReminder();
// String CRON_EXP = '0 0 6 ? * MON-FRI';
// String jobID = System.schedule('Center Support Request Submit Reminder ENV:PROD', CRON_EXP, centerSupportRequestSubmitReminder);

// To delete the CronTrigger, run the following the dev console:

// CronTrigger cron = [SELECT Id
//                     FROM CronTrigger
//                     WHERE CronJobDetail.Name = 'Center Support Request Submit Reminder ENV:PROD'];
// System.abortJob(cron.Id);