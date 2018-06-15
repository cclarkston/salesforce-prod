/*
05/31/2018  CC  Initial commit
06/11/2018	CC	Added TextReminderTrue and TextReminderFalse
*/

public with sharing class Constants {

	public Constants() {

	}

	//Email constants
	public static final String SalesforceAdminEmail = 'sfdcadmin@clearchoice.com';
	public static final String CareConnectionEmail = 'cclarkston@clearchoice.com';
	public static final String IncomingSMSEmailSubject = 'SMS Received';
	public static final String IncomingSMSOnlineEmailSubject = 'Online SMS Respond';
	public static final String OutgoingSMSEmailSubject = 'SMS Sent';
	public static final String OutgoingSMSOnlineEmailSubject = 'Online SMS Sent';
	//Activity constants
    public static final String OnlineIncomingSMSActivityType = 'Online SMS Respond';
    public static final String ManualIncomingSMSActivityType = 'Incoming Text';
    public static final String OnlineOutgoingSMSActivityType = 'Online SMS Sent';
    public static final String ManualOutgoingSMSActivityType = 'SMS Sent';
	public static final String MessageNotSentNotOptIn = 'Not Sent - Not opt in';
	//Reminder
    public static final String TextReminderTrue = 'Yes';
    public static final String TextReminderFalse = 'No';
	//SMS status
	public static final String MessageSuccess = 'success';

	public static String ForUnitTest () {
		return 'ForUnitTest';
	}
}