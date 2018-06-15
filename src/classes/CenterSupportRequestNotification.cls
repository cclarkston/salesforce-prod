public class CenterSupportRequestNotification {
	private static Boolean sandbox = Test.isRunningTest() || [SELECT IsSandbox
	                                                          FROM Organization
	                                                          LIMIT 1][0].IsSandbox;

	private static String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
	private static String[] projectManagersEmail;
	private static String[] csrMonitorsEmail;
	private static Datetime supervisorTarget = Datetime.now().addDays(-2);

	public static void sendRequestCreatedNotification(String requestId, String requestName) {
		csrMonitorsEmail();

		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String requestURl = baseUrl + '/' + requestId;

		mail.setToAddresses(csrMonitorsEmail);
		mail.setReplyTo('donotreply@clearchoice.com');
		mail.setSenderDisplayName('Center Support Request');
		mail.setSubject('Center Support Request Created: ' + requestName);
		mail.setBccSender(false);
		mail.setUseSignature(false);
		mail.setPlainTextBody(
				'This email has been sent to let you know Center Support Request: '
				+ requestName + ' has been created.' +
				'Thank you!');
		mail.setHtmlBody(
				'This email has been sent to let you know Center Support Request:<b> '
				+ requestName + ' </b>has been created.<p>'+
				'To view the Center Support Request <a href=' + requestUrl +'>click here.</a><p>'+
				'Thank you!');

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	public static void sendRequestClosedNotification(String approverName, String[] emailAddresses,
			String requestId, String requestName) {
		projectManagersEmail();
		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String requestURl = baseUrl + '/' + requestId;

		mail.setToAddresses(emailAddresses);
		mail.setBccAddresses(projectManagersEmail);
		mail.setReplyTo('donotreply@clearchoice.com');
		mail.setSenderDisplayName('Center Support Request');
		mail.setSubject('Center Support Request Closed: ' + requestName);
		mail.setUseSignature(false);
		mail.setPlainTextBody(
				'Dear ' + approverName + ', ' +
				'This email has been sent to let you know Center Support Request: ' +
				requestName + ' has been closed.' +
				'Thank you!');
		mail.setHtmlBody(
				'Dear ' + approverName + ', <p>' +
				'This email has been sent to let you know Center Support Request:<b> ' +
				requestName + ' </b>has been closed.<p>' +
				'To view the Center Support Request <a href=' + requestUrl +'>click here.</a><p>'+
				'Thank you!');

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	public static void sendApprovalReminder(Center_Support_Request__c[] requests) {
		projectManagersEmail();

		List<Messaging.SingleEmailMessage> builtEmail = new List<Messaging.SingleEmailMessage>();
		for (Integer i = 0; i < requests.size(); i++) {
			List<String> toAddresses = new List<String>();
			String approverName = requests.get(i).Center_Information__r.Region__r.RBD__r.FirstName;

			System.debug('Approver Name: ' + approverName);

			toAddresses.add(requests.get(i).Center_Information__r.Region__r.RBD__r.Email);

			if(requests.get(i).Submitted_Date_Time__c < supervisorTarget) {
				toAddresses.add(requests.get(i).Center_Information__r.Region__r.Sales_Area__r.Area_Vp__r.Email);
			}

			String requestId = requests.get(i).Id;
			String requestName = requests.get(i).Name;
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String requestURl = baseUrl + '/' + requestId;
			mail.setToAddresses(toAddresses);
			mail.setBccAddresses(projectManagersEmail);
			mail.setReplyTo('donotreply@clearchoice.com');

			mail.setSenderDisplayName('Center Support Request');
			mail.setSubject('Center Support Request REMINDER : ' + requestName);
			mail.setUseSignature(false);
			mail.setPlainTextBody(
					'Dear ' + approverName + ', ' +
					'This email has been sent to let you know Center Support Request: ' +
					requestName + ' is waiting for your approval.' +
					'Thank you!');
			mail.setHtmlBody(
					'Dear ' + approverName + ', <p>' +
					'This email has been sent to let you know Center Support Request:<b> ' +
					requestName + ' </b>is waiting for your approval.<p>' +
					'To view the Center Support Request <a href=' + requestUrl +'>click here.</a><p>'+
					'Thank you!');
			builtEmail.add(mail);
		}
		List<Messaging.Email> collatedEmail = collateEmail(builtEmail);
		sendEmail(collatedEmail);
	}


	public static String getManagerEmailAddress(ID userID){
		Integer only        = 0;
		User[] user = [SELECT Manager.Email FROM User WHERE Id = :userID LIMIT 1];
		System.debug('managerEmail: '+ user.get(0).Manager.Email);
		if(user.size() < 1){
			return '';
		}
		return user.get(0).Manager.Email;
	}

	/**
	 **
	 */
	public static void sendSubmitReminder(Center_Support_Request__c[] requests) {
		List<Messaging.SingleEmailMessage> builtEmail = new List<Messaging.SingleEmailMessage>();

		for(Center_Support_Request__c request : requests) {
			List<String> toAddresses = new List<String>();
			ID createdById = request.CreatedById;
			Boolean dateInSupervisorTargetRange = supervisorTarget <= request.CreatedDate;
			String ownerName = request.CreatedBy.FirstName;
			toAddresses.add(request.CreatedBy.Email);
			String managerEmailAddress = '';

			if(dateInSupervisorTargetRange){
				managerEmailAddress = getManagerEmailAddress(request.CreatedById);
				System.debug('managerEmailAddress: ' + managerEmailAddress);
			}

			System.debug('Environment: ' + sandbox);

			if(sandbox) {
				toAddresses.add(request.CreatedBy.Email);
				toAddresses.add('donotreply@clearchoice.com');
			}
			else if((managerEmailAddress != '')
					&& dateInSupervisorTargetRange) {
				toAddresses.add(managerEmailAddress);
			}

			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String requestURl = baseUrl + '/' + request.Id;

			mail.setToAddresses(toAddresses);
			mail.setBccAddresses(projectManagersEmail);
			mail.setReplyTo('donotreply@clearchoice.com');
			mail.setSenderDisplayName('Center Support Request');
			mail.setSubject('Center Support Request REMINDER');
			mail.setUseSignature(false);
			mail.setPlainTextBody(
					'Dear ' + ownerName + ', ' +
					'This email has been sent to let you know a Center Support Request was ' +
					'created but not submitted for approval.' +
					'Thank you!');
			mail.setHtmlBody(
					'Dear ' + ownerName + ', <p>' +
					'This email has been sent to let you know a Center Support Request was ' +
					'created but not submitted for approval.<p>' +
					'To view and submit the Center Support Request <a href=' + requestUrl +'>click here.</a><p>'+
					'Thank you!');

			builtEmail.add(mail);
		}
		List<Messaging.Email> collatedEmail = collateEmail(builtEmail);
		sendEmail(collatedEmail);
	}

	private static List<Messaging.Email> collateEmail(List<Messaging.SingleEmailMessage> builtEmail) {
		List<Messaging.Email> allEmail = new List<Messaging.Email>();
		for (Integer i = 0; i < builtEmail.size(); i++) {
			allEmail.add(builtEmail.get(i));
		}
		return allEmail;
	}

	private static void sendEmail(List<Messaging.Email> collatedEmail) {
		Messaging.sendEmail(collatedEmail);
	}

	public static void sendWeeklyNotes(List<String> emailAddresses, String emailBody) {
		projectManagersEmail();
		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setToAddresses(projectManagersEmail);
		mail.setBccAddresses(emailAddresses);
		mail.setReplyTo('donotreply@clearchoice.com');
		mail.setSenderDisplayName('Center Support Request');
		mail.setSubject('Center Support Request - Weekly Updates');
		mail.setUseSignature(false);
		mail.setPlainTextBody(
				'In order to view the weekly updates you mush be able to recieve HTML email.'
				+ 'Contact the Help Desk for assistance.');
		mail.setHtmlBody(emailBody);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	private static void projectManagersEmail() {
		if(sandbox) {
			projectManagersEmail = new String[] {'software-dev@clearchoice.com'};
		} else {
			projectManagersEmail = new String[] {'rsutula@clearchoice.com'};
		}
	}

	private static void csrMonitorsEmail() {
		if(sandbox) {
			csrMonitorsEmail = new String[] {'software-dev@clearchoice.com'};
		} else {
			csrMonitorsEmail = new String[] {'tdeyoung@clearchoice.com'};
		}
	}
}