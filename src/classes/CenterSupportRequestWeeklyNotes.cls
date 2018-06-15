global class CenterSupportRequestWeeklyNotes implements Schedulable {
	global void execute(SchedulableContext context) {
		Boolean sandbox = Test.isRunningTest() || [SELECT IsSandbox
		                                           FROM Organization
		                                           LIMIT 1][0].IsSandbox;

		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
		Set<Id> requestIds = new Set<Id>();
		Map<Id, Center_Support_Request__c> centersByParentId;
		String emailBody = '';
		String noteUrl = '';
		String[] emailAddresses;

		if (sandbox) {
			emailAddresses = new String[]{'software-dev@clearchoice.com'};
		}
		else {
			emailAddresses = new String[]{'csr@clearchoice.com'}; // google group managed by IT
		}

		Note[] notes = [SELECT Id, ParentId, Title, CreatedBy.Name
		                FROM Note
		                WHERE ParentId IN
		                (SELECT Id FROM Center_Support_Request__c)
		                AND LastModifiedDate > LAST_WEEK];

		for(Note note: notes) {
			requestIds.add(note.ParentId);
		}

		centersByParentId = new Map<Id, Center_Support_Request__c>
		([SELECT Id, Center_Information__r.Name
		  FROM Center_Support_Request__c
		  WHERE Id IN :requestIds]);

		for(Note note: notes) {
			noteUrl = baseUrl + '/' + note.Id;

			emailBody += '<p><u>Center</u>: ';
			emailBody += centersByParentId.get(note.ParentId).Center_Information__r.Name;
			emailBody += '<p><u>Title</u>: ';
			emailBody += note.Title;
			emailBody += '<p><u>From</u>: ';
			emailBody += note.CreatedBy.Name;
			emailBody += '<p><a href="';
			emailBody += noteUrl;
			emailBody += '">';
			emailBody += 'Click here to view notes';
			emailBody += '</a>';
			emailBody += '</br></br><hr></br></br>';
		}

		if(notes.size() != 0) {
  		try {
  			CenterSupportRequestNotification.sendWeeklyNotes(emailAddresses, emailBody);
  		}
  		catch(DmlException error) {
  			System.debug('There was an error sending the Center Support Request '
  					+ 'Weekly Update: ' + error);
  		}
		}
	}
}

// Executed in the dev console to initialize the CronTrigger:

// CenterSupportRequestWeeklyNotes centerSupportRequestWeeklyNotes = new CenterSupportRequestWeeklyNotes();
// String CRON_EXP = '0 0 7 ? * MON *';
// String jobID = System.schedule('Center Support Request Weekly Notes ENV:PROD', CRON_EXP, centerSupportRequestWeeklyNotes);
//
// To delete the CronTrigger, run the following the dev console:

// CronTrigger cron = [SELECT Id
//                     FROM CronTrigger
//                     WHERE CronJobDetail.Name = 'Center Support Request Weekly Notes ENV:PROD'];
// System.abortJob(cron.Id);