// tests afterCenter.trigger

@isTest
private class TestAfterCenterTrigger {
  private class TestException extends Exception {}

  static Id profileId = [SELECT Id
                         FROM Profile
                         WHERE Name = 'Standard User'
                         LIMIT 1
                       ].Id;

  static User rbd;
  static Sales_Region__c region;
  static Center_Information__c center;

  private static void init() {
    rbd = new User(Username = 'rbd@clearchoice.com',
                   LastName = 'RBD',
                   Email = 'rbd@clearchoice.com',
                   Alias = 'rbd',
                   CommunityNickname = 'rbd',
                   TimeZoneSidKey = 'America/Denver',
                   EmailEncodingKey = 'UTF-8',
                   ProfileId = profileId,
                   LanguageLocaleKey = 'en_US',
                   LocaleSidKey='en_US'
                 );
   insert rbd;

   region = new Sales_Region__c(Name = 'Test Region',
                                RBD__c = rbd.Id
                              );
   insert region;

   center =  new Center_Information__c(Name = 'Test Center',
                                       Region__c = region.Id,
                                       Latlong__Longitude__s = 30,
                                       Latlong__Latitude__s = 30
                                     );
   insert center;
  }

  static TestMethod void testAccountNameUpdateValidationForAuthorizedProfiles() {
    init();

    String originalCenterName = center.Name;
    center.Name = 'Update Center Name';
    update center;

    String updatedCenterName = [SELECT Name
                                FROM Center_Information__c
                                WHERE Id = :center.Id].Name;

    System.assertNotEquals(originalCenterName, updatedCenterName);
  }

  static TestMethod void testAccountNameUpdateValidationForUnauthorizedProfiles() {
    init();

    // run test as a user that has a Standard User profile and is not
    // in the set of authorizedProfiles in afterCenter.trigger
    System.runAs(rbd) {

      // unique center created by runAs user prevents error:
      // INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
      Center_Information__c center =  new Center_Information__c(Name = 'Test Center',
                                                                Region__c = region.Id,
                                                                Latlong__Longitude__s = 30,
                                                                Latlong__Latitude__s = 30
                                                              );
      insert center;

      try {
        center.Name = 'Update Center Name';
        update center;
        // exception ensures center is not updated successfully
        // in which case the test would appear to pass
        throw new TestException('afterCenter.trigger should have run .addError '
                              + 'on center.Name and invalidate the update. '
                              + 'test must be runAs user not in authorizedProfiles');
      } catch(Exception error) {
        System.debug(error.getMessage());
        System.Assert(error.getMessage().contains('Update failed.'));
        System.Assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.Assert(error.getMessage().contains('You do not have permission to '
                                                  + 'change the name of a center. '
                                                  + 'Please contact IT for assistance.')
                                                );
      }
    }
  }
}