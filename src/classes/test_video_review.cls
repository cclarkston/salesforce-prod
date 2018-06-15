/*
    KS 
    2017-4-4
    ctrl_video_review: 100%
*/

@isTest

private class test_video_review {

  private static void init() {

    // User <-- Video__c --> Account__c --> Center__c --> Region__c

    Sales_Region__c region = new Sales_Region__c(Name = 'Test Region');
    insert region;

    Center_Information__c center = new Center_Information__c(Name = 'Test Center', Region__c = region.Id, latlong__Longitude__s = 30, latlong__Latitude__s = 30);
    insert center;

    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;

    Account account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = center.id, RecordTypeId = rid);
    insert account;

    Video__c video1 = new Video__c(Account__c = account.Id, Link__c = 'http://video_url1.com', Type__c = 'Patient Consult');
    Video__c video2 = new Video__c(Account__c = account.Id, Link__c = 'http://video_url2.com', Type__c = 'Doctor Download');
    Video__c video3 = new Video__c(Account__c = account.Id, Link__c = 'http://video_url3.com', Type__c = 'Roleplay');
    insert new Video__c[]{video1, video2, video3};
  }

  @isTest static void test_it_returns_expected_records() {
    init();
    ctrl_video_review controller = new ctrl_video_review();
    controller.getregion_options();
    controller.getcenter_options();
    controller.getPEC_options();
    controller.gettype_options();

    Test.StartTest();
      controller.prepare_videos();
    Test.StopTest();

    System.assertEquals(3, controller.videos.size());
  }

  @isTest static void test_it_returns_expected_records_with_filters() {
    init();
    ctrl_video_review controller = new ctrl_video_review();
    controller.type = 'Patient Consult';

    Test.StartTest();
      controller.prepare_videos();
    Test.StopTest();

    System.assertEquals(1, controller.videos.size());
    Video__c video = controller.videos[0];
    System.assertEquals('Test Region', video.Account__r.Center__r.Region__r.Name);
    System.assertEquals('Test Center', video.Account__r.Center__r.Name);
    System.assertEquals('Test Account', video.Account__r.Name);
    System.assertEquals('http://video_url1.com', video.Link__c);
    System.assertEquals('Patient Consult', video.Type__c);
  }
}