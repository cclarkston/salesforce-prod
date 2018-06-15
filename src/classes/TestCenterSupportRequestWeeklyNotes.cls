@isTest
private class TestCenterSupportRequestWeeklyNotes {
  public static String CRON_EXP = '0 0 6 * * ?';

  @TestSetup
  static void setup() {
    String validRequestType = Utilities.picklist_values(
                                    'Center_Support_Request__c', 'Type__c')[0];

    Profile standardProfile = [SELECT Id
                               FROM Profile
                               WHERE Name = 'Standard User'
                               LIMIT 1
                             ];

    User user = new User(FirstName = 'Test',
                         LastName = 'CenterSupportUser',
                         Alias = 'alias',
                         UserName = 'center-support-user@clearchoice.com',
                         ProfileId = standardProfile.Id,
                         Email = 'software-dev@clearchoice.com',
                         TimeZoneSidKey = 'America/Los_Angeles',
                         EmailEncodingKey = 'UTF-8',
                         LanguageLocaleKey = 'en_US',
                         LocaleSidKey = 'en_US');
    insert user;

    Sales_Region__c region = new Sales_Region__c(Active__c = true,
                                                 RBD__c = user.Id);
    insert region;

    Center_Information__c center = new Center_Information__c(
                                                   Name = 'Test Center',
                                                   Region__c = region.Id,
                                                   latlong__Longitude__s = 30,
                                                   latlong__Latitude__s = 30
                                                 );
    insert center;


    Center_Support_Request__c request = new Center_Support_Request__c(
                                              Type__c = validRequestType,
                                              Center_Information__c = center.Id,
                                              Summary__c = 'Test Summary',
                                              Need_by_date__c = Date.today(),
                                              Status__c = 'Closed',
                                              Legal_Compliance__c = 'No'
                                            );
    insert request;

    Note note = new Note(parentId = request.Id,
                         Title = 'Test Title',
                         Body = 'test body',
                         isPrivate = false);
   insert note;
  }

  static testMethod void sendWeeklyNotes() {
    CronTrigger[] cron = [SELECT Id
                          FROM CronTrigger
                          WHERE CronJobDetail.Name =
                                        'Center Support Request Weekly Notes'];

    System.assertEquals(cron.size(), 0);

    Test.startTest();
    String jobId = System.schedule('Center Support Request Weekly Notes',
                                   CRON_EXP,
                                   new CenterSupportRequestWeeklyNotes());
    Test.stopTest();

    CronTrigger[] cronScheduled = [SELECT Id
                                   FROM CronTrigger
                                   WHERE CronJobDetail.Name =
                                        'Center Support Request Weekly Notes'];

    System.assertEquals(cronScheduled.size(), 1);
  }
}