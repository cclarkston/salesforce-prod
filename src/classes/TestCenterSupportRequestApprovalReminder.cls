@isTest
private class TestCenterSupportRequestApprovalReminder {
  public static String CRON_EXP = '0 0 6 * * ?';

  @testSetup
  static void setup() {
    User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    String validRequestType = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
    Date needByDate = Date.today();
    Datetime dateSubmitted = Datetime.now();

    List<Center_Support_Request__c> requests = new List<Center_Support_Request__c>();

    Sales_Area__c salesArea = new Sales_Area__c(Name  = 'Northeast', Area_VP__c = UserInfo.getUserId());
    insert salesArea;

    Sales_Region__c region = new Sales_Region__c(Name = 'Test Region', RBD__c = UserInfo.getUserId(),
                                                 Sales_Area__c = salesArea.Id);
    insert region;

    Center_Information__c center = new Center_Information__c(Name = 'Test Center',
                                                             Region__c = region.Id,
                                                             latlong__Longitude__s = 30,
                                                             latlong__Latitude__s = 30);
    insert center;

    System.runAs(currentUser){
      Integer count = 1;
      for(Integer i=0; i<10; i++) {

        Center_Support_Request__c request = new Center_Support_Request__c(
                                        Center_Information__c = center.Id,
                                        Type__c = validRequestType,
                                        Summary__c = 'Test Summary',
                                        Need_by_date__c = needByDate,
                                        Submitted_for_Approval__c = true,
                                        Submitted_Date_Time__c = dateSubmitted,
                                        Approval_Reminder_Count__c = count,
                                        Status__c = 'Open',
                                        Legal_Compliance__c = 'No'
                                      );
        requests.add(request);
      }
      insert requests;
    }
  }

  static testMethod void centerSupportRequestApprovalReminderHandlesNoRequests() {
    Datetime target = Datetime.now().addDays(-2);

    Test.StartTest();
      String jobId = System.schedule('Center Support Request Approval Reminder',
                                     CRON_EXP,
                                     new CenterSupportRequestApprovalReminder());
    Test.StopTest();

    Center_Support_Request__c[] requests = [SELECT Id
                                            FROM Center_Support_Request__c
                                            WHERE Submitted_for_Approval__c = true
                                            AND CreatedDate < :target];

    System.assertEquals(0, requests.size());
	}

  static testMethod void centerSupportRequestApprovalReminder() {
    Datetime target = Datetime.now().addDays(-2);
    Datetime submittedDate = Datetime.now().addDays(-4);

    Center_Support_Request__c request = [SELECT Id from Center_Support_Request__c
                                         LIMIT 1];
    request.Submitted_Date_Time__c = submittedDate;
    update request;

    Test.StartTest();
      String jobId = System.schedule('Center Support Request Approval Reminder',
                                     CRON_EXP,
                                     new CenterSupportRequestApprovalReminder());
    Test.StopTest();

    Center_Support_Request__c processedRequest = [SELECT Approval_Reminder_Count__c
                                                  FROM Center_Support_Request__c
                                                  WHERE Submitted_for_Approval__c = true
                                                  AND Submitted_Date_Time__c < :target
                                                  AND Id = :request.Id];

    System.assertEquals(2, processedRequest.Approval_Reminder_Count__c);
	}
}