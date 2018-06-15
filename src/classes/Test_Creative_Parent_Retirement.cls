/*
3/29/16
Classes:
  Creative_Button_Parent_Retirement - 100%
Triggers:
  Creative_Copy_Details_From_Parent_to_Child - 90%
*/

@isTest

private class Test_Creative_Parent_Retirement {

    private static void init(Boolean retirement_status) {
      create_projects(1);
      create_parent_assets(1, retirement_status);
      create_public_ads(1);
      create_acting_user();
    }

    static testMethod void test_it_retires_parent_with_a_reason_when_given_true_retirement_status() {
      Boolean retirement_status = true;
      init(!retirement_status);
      User acting_user = [Select Name From User Where Email = 'alon@alon.alon'];
      Creative__c parent = parent_from_DB();

      System.assertNotEquals(true, parent.Retired__c);

      Test.startTest();
        Creative_Button_Parent_Retirement.retire(parent.id, acting_user.id, retirement_status, 'Retire reason');
        parent = parent_from_DB();

        System.assertEquals(true, parent.Retired__c);
        System.assertEquals('Retired by ' + acting_user.Name + ': Retire reason', parent.Retirement_Reason__c);
      Test.stopTest();
    }

    static testMethod void test_it_unretires_parent_with_a_reason_when_given_false_retirement_status() {
      Boolean retirement_status = false;
      init(!retirement_status);
      User acting_user = [Select Name From User Where Email = 'alon@alon.alon'];
      Creative__c parent = parent_from_DB();

      System.assertNotEquals(false, parent.Retired__c);

      Test.startTest();
        Creative_Button_Parent_Retirement.retire(parent.id, acting_user.id, retirement_status, null);
        parent = parent_from_DB();

        System.assertEquals(false, parent.Retired__c);
        System.assertEquals('UnRetired by ' + acting_user.Name + ' on ' + Date.today().format(), parent.Retirement_Reason__c);
      Test.stopTest();
    }

    static testMethod void test_it_retires_public_ad_with_a_reason_when_parent_is_retired() {
      Boolean retirement_status = true;
      init(!retirement_status);
      User acting_user = [Select Name From User Where Email = 'alon@alon.alon'];
      Creative__c parent = parent_from_DB();
      Creative__c public_ad = public_ad_from_DB(parent);

      System.assertNotEquals(true, public_ad.Retired__c);

      Test.startTest();
        Creative_Button_Parent_Retirement.retire(parent.id, acting_user.id, retirement_status, 'Retire reason');
        public_ad = public_ad_from_DB(parent);

        System.assertEquals(true, public_ad.Retired__c);
        System.assertEquals(acting_user.Name + ' retired the parent, \'' + parent.Name__c + '\': Retire reason', public_ad.Retirement_Reason__c);
      Test.stopTest();
    }

    static testMethod void test_it_unretires_public_ad_with_a_reason_when_parent_is_retired() {
      Boolean retirement_status = false;
      init(!retirement_status);
      User acting_user = [Select Name From User Where Email = 'alon@alon.alon'];
      Creative__c parent = parent_from_DB();
      Creative__c public_ad = public_ad_from_DB(parent);

      System.assertNotEquals(false, public_ad.Retired__c);

      Test.startTest();
        Creative_Button_Parent_Retirement.retire(parent.id, acting_user.id, retirement_status, 'Retire reason');
        public_ad = public_ad_from_DB(parent);

        System.assertEquals(false, public_ad.Retired__c);
        System.assertEquals(acting_user.Name + ' unretired the parent, \'' + parent.Name__c + '\', on ' + Date.today().format(), public_ad.Retirement_Reason__c);
      Test.stopTest();
    }



            private static void create_projects(Integer count) {
                for (Integer i = 1; i <= count; i++) {
                    insert new Creative_Project__c(Name = 'Project ' + i);
                }
            }

            private static void create_parent_assets(Integer count, Boolean retirement_status) {
                RecordType parent_asset_recordtype = [Select ID
                                                      From RecordType
                                                      Where sObjectType = 'Creative__c'
                                                      And Name = 'Parent Asset'
                                                      Limit 1];

                Creative_Project__c[] projects = [Select ID From Creative_Project__c];

                Creative__c[] parents = new Creative__c[]{};
                    for (Integer i = 1; i <= count; i++) {
                        parents.add(new Creative__c(RecordTypeID = parent_asset_recordtype.id,
                                                    Project__c	= projects[i - 1].id,
                                                    Retired__c	= retirement_status));
                    }
                insert parents;
            }

            private static void create_public_ads(Integer count) {
                RecordType public_ad_recordtype = [Select ID
                                                   From RecordType
                                                   Where sObjectType = 'Creative__c'
                                                   And Name = 'Public Ad'
                                                   Limit 1];

                Creative__c parent = [Select Retired__c
                                      From Creative__c
                                      Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Parent Asset'
                                      Limit 1];

                Creative__c[] public_ads = new Creative__c[]{};
                    for (Integer i = 1; i <= count; i++) {
                        public_ads.add(new Creative__c(RecordTypeID		= public_ad_recordtype.id,
                                                       Parent_Asset__c	= parent.id,
                                                       Retired__c		= parent.Retired__c));
                    }
                insert public_ads;
            }

            private static void create_acting_user() {
              ID profile_id = [Select ID From Profile Limit 1].id;
              insert new User(isActive = true,
                              Username = 'alon@alon.alon', FirstName = 'Test', LastName = 'User', Email = 'alon@alon.alon', Alias = 'null', CommunityNickname = 'alon', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = profile_id, LanguageLocaleKey = 'en_US');
            }

            private static Creative__c parent_from_DB() {
                return [Select Name__c, Retired__c, Retirement_Reason__c
                        From Creative__c
                        Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Parent Asset'
                        Limit 1];
            }

            private static Creative__c public_ad_from_DB(Creative__c parent) {
                return [Select Parent_Asset__c, Retired__c, Retirement_Reason__c
                        From Creative__c
                        Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'
                        And Parent_Asset__c = :parent.id];
            }
}