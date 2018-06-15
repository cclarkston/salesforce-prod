global class CenterSupportRequestApprovalReminder implements Schedulable {

  global void execute(SchedulableContext context) {
    Datetime target = Datetime.now().addDays(-1);

    Center_Support_Request__c[] requests = [SELECT Id, Name,
                                            Approval_Reminder_Count__c,
                                            Center_Information__r.Region__r.RBD__r.FirstName,
                                            Center_Information__r.Region__r.RBD__r.Email,
                                            Center_Information__r.Region__r.Sales_Area__r.Area_Vp__r.Email,
                                            Submitted_Date_Time__c
                                            FROM Center_Support_Request__c
                                            WHERE Submitted_for_Approval__c = true
                                            AND Status__c = 'Open'
                                            AND Approved__c = false
                                            AND Submitted_Date_Time__c < :target
                                          ];

    if(requests.size() != 0) {
      for(Center_Support_Request__c request : requests) {
        request.Approval_Reminder_Count__c += 1;
      }

      try {
      	CenterSupportRequestNotification.sendApprovalReminder(requests);
      } catch (DmlException error) {
        System.debug('The following exception has occurred: ' + error.getMessage());
      }
      try {
        update requests;
      } catch(DmlException error) {
        System.debug('The following exception has occurred: ' + error.getMessage());
      }
    }
  }
}

// Execute to initialize the CronTrigger:

// CenterSupportRequestApprovalReminder centerSupportRequestApprovalReminder = new CenterSupportRequestApprovalReminder();
// String CRON_EXP = '0 0 6 ? * MON-FRI';
// String jobID = System.schedule('Center Support Request Approval Reminder ENV:PROD', CRON_EXP, centerSupportRequestApprovalReminder);

// To delete the CronTrigger, run the following the dev console:

// CronTrigger cron = [SELECT Id
//                     FROM CronTrigger
//                     WHERE CronJobDetail.Name = 'Center Support Request Approval Reminder ENV:PROD'];
// System.abortJob(cron.Id);