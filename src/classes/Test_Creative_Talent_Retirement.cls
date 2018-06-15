/*
3/30/16
Classes:
  Creative_Button_Retire_from_Talent - 100%
Triggers:
  Creative_Copy_Details_From_Parent_to_Child - 88%
  Extra_after_insert_copy_to_Talent - 100%
*/

@isTest

private class Test_Creative_Talent_Retirement {

  private static void init(Integer shoot_count, Integer parents_per_shoot, Integer public_ads_per_parent, Boolean retirement_status) {
    Map<String, ID>     record_type_ids = creative_record_type_ids();
    Extra__c            extra           = new_extra();
    Talent__c           talent          = new_talent(extra);
    Creative_Shoot__c[] shoots          = new_creative_shoots(shoot_count);
    Creative_Project__c project         = new_project();
    Creative__c[]       parents         = new_parent_assets(shoot_count * parents_per_shoot, record_type_ids, project);
    create_talent_appearances(talent, shoots);
    create_asset_to_shoot_connections(shoots, parents);
    create_public_ads(public_ads_per_parent, record_type_ids, parents, retirement_status);
    create_acting_user();
  }

  static testMethod void test_it_retires_a_Talents_related_PublicAd_with_a_reason_when_given_true_retirement_status() {
    Boolean retirement_status = true;
    init(1, 1, 1, !retirement_status);
    User acting_user = [Select Name From User Where Name = 'Acting User'];
    Talent__c talent = [Select Name__c From Talent__c Limit 1];
    Creative__c[] public_ads = public_ads_from_DB();
    system.assertNotEquals(retirement_status, public_ads[0].Retired__c);

    test.startTest();
      Creative_Button_Retire_from_Talent.retire(talent.id, acting_user.id, retirement_status, 'Retire reason');
      public_ads = public_ads_from_DB();

      system.assertEquals(retirement_status, public_ads[0].Retired__c);
      system.assertEquals('Talent, ' + talent.Name__c + ', retired by ' + acting_user.Name + ': Retire reason', public_ads[0].Retirement_Reason__c);
    test.stopTest();
  }

  static testMethod void test_it_unretires_a_Talents_related_PublicAd_with_a_reason_when_given_true_retirement_status() {
    Boolean retirement_status = false;
    init(1, 1, 1, !retirement_status);
    User acting_user = [Select Name From User Where Name = 'Acting User'];
    Talent__c talent = [Select Name__c From Talent__c Limit 1];
    Creative__c[] public_ads = public_ads_from_DB();
    system.assertNotEquals(retirement_status, public_ads[0].Retired__c);

    test.startTest();
      Creative_Button_Retire_from_Talent.retire(talent.id, acting_user.id, retirement_status, null);
      public_ads = public_ads_from_DB();

      system.assertEquals(retirement_status, public_ads[0].Retired__c);
      system.assertEquals('Talent, ' + talent.Name__c + ', unretired by ' + acting_user.Name + ' on ' + Date.today().format(), public_ads[0].Retirement_Reason__c);
    test.stopTest();
  }

  static testMethod void test_it_retires_all_a_Talents_related_PublicAds_with_a_reason_when_given_true_retirement_status() {
    Boolean retirement_status = true;
    init(2, 2, 2, !retirement_status);
    User acting_user = [Select Name From User Where Name = 'Acting User'];
    Talent__c talent = [Select Name__c From Talent__c Limit 1];
    Creative__c[] public_ads = public_ads_from_DB();
    system.assertEquals(8, public_ads.size());
    for (Creative__c public_ad : public_ads) {system.assertNotEquals(retirement_status, public_ad.Retired__c);}

    test.startTest();
      Creative_Button_Retire_from_Talent.retire(talent.id, acting_user.id, retirement_status, 'Retire reason');
      public_ads = public_ads_from_DB();

      for (Creative__c public_ad : public_ads) {system.assertEquals(retirement_status, public_ad.Retired__c);}
      for (Creative__c public_ad : public_ads) {system.assertEquals('Talent, ' + talent.Name__c + ', retired by ' + acting_user.Name + ': Retire reason', public_ad.Retirement_Reason__c);}
    test.stopTest();
  }

  static testMethod void test_it_unretires_all_a_Talents_related_PublicAds_with_a_reason_when_given_true_retirement_status() {
    Boolean retirement_status = false;
    init(2, 2, 2, !retirement_status);
    User acting_user = [Select Name From User Where Name = 'Acting User'];
    Talent__c talent = [Select Name__c From Talent__c Limit 1];
    Creative__c[] public_ads = public_ads_from_DB();
    system.assertEquals(8, public_ads.size());
    for (Creative__c public_ad : public_ads) {system.assertNotEquals(retirement_status, public_ad.Retired__c);}

    test.startTest();
      Creative_Button_Retire_from_Talent.retire(talent.id, acting_user.id, retirement_status, 'Retire reason');
      public_ads = public_ads_from_DB();

      for (Creative__c public_ad : public_ads) {system.assertEquals(retirement_status, public_ad.Retired__c);}
      for (Creative__c public_ad : public_ads) {system.assertEquals('Talent, ' + talent.Name__c + ', unretired by ' + acting_user.Name + ' on ' + Date.today().format(), public_ad.Retirement_Reason__c);}
    test.stopTest();
  }



        private static Map<String, ID> creative_record_type_ids() {
          Map<String, ID> record_type_ids = new Map<String, ID>();
          RecordType[] record_types = [Select Name
                                     From RecordType
                                     Where sObjectType = 'Creative__c'
                                     And (Name = 'Parent Asset' OR Name = 'Public Ad')];
          for (RecordType record_type : record_types) {
            record_type_ids.put(record_type.Name, record_type.id);
          }
          return record_type_ids;
        }

        private static Extra__c new_extra() {
          Extra__c extra = new Extra__c(Name = 'Extra Person');
          insert extra;
          return extra;
        }

        private static Talent__c new_talent(Extra__c extra) {
          Talent__c talent = new Talent__c();
          if ([Select Count() From Talent__c Where Extra__c = :extra.id] == 0) {
            talent = new Talent__c(Extra__c = extra.id);
            insert talent;
          }
          else talent = [Select ID From Talent__c Where Extra__c = :extra.id];
          return talent;
        }

        private static Creative_Shoot__c[] new_creative_shoots(Integer count) {
          Creative_Shoot__c[] shoots = new Creative_Shoot__c[]{};
          for (Integer i = 1; i <= count; i++) {
            shoots.add(new Creative_Shoot__c(Location__c = 'Location ' + i, Date__c = Date.today()));
          }
          insert shoots;
          return shoots;
        }

        private static void create_talent_appearances(Talent__c talent, Creative_Shoot__c[] shoots) {
          Talent_Appearance__c[] appearances = new Talent_Appearance__c[]{};
          for (Creative_Shoot__c shoot : shoots) {
            appearances.add(new Talent_Appearance__c(Talent__c = talent.id, Creative_Shoot__c = shoot.id));
          }
          insert appearances;
        }

        private static Creative_Project__c new_project() {
          Creative_Project__c project = new Creative_Project__c(Name = 'Project Name');
          insert project;
          return project;
        }

        private static Creative__c[] new_parent_assets(Integer count, Map<String, ID> record_type_ids, Creative_Project__c project) {
          Creative__c[] parents = new Creative__c[]{};
          for (Integer i = 0; i < count; i++) {
            parents.add(new Creative__c(RecordTypeID = record_type_ids.get('Parent Asset'),
                                        Project__c   = project.id));
          }
          insert parents;
          return parents;
        }

        private static void create_asset_to_shoot_connections(Creative_Shoot__c[] shoots, Creative__c[] parents) {
          Asset_to_Shoot_Connection__c[] connections = new Asset_to_Shoot_Connection__c[]{};
          Integer shoot_count = shoots.size();
          Integer index = 0;

          for (Creative__c parent : parents) {
            connections.add(new Asset_to_Shoot_Connection__c(Creative__c = parent.id,
                                                             Creative_Shoot__c = shoots[Math.mod(index++, shoot_count)].id));
          }
          insert connections;
        }

        private static void create_public_ads(Integer count, Map<String, ID> record_type_ids, Creative__c[] parents, Boolean retirement_status) {
          Creative__c[] public_ads = new Creative__c[]{};
          for (Creative__c parent : parents) {
            for (Integer i = 0; i < count; i++) {
              public_ads.add(new Creative__c(RecordTypeID = record_type_ids.get('Public Ad'),
                                             Parent_Asset__c = parent.id,
                                             Retired__c = retirement_status));
            }
          }
          insert public_ads;
        }


        private static void create_acting_user() {
          ID profile_id = [Select ID From Profile Limit 1].id;
          insert new User(isActive = true,
                          Username = 'alon@alon.alon', FirstName = 'Acting', LastName = 'User', Email = 'alon@alon.alon', Alias = 'null', CommunityNickname = 'alon', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = profile_id, LanguageLocaleKey = 'en_US');
        }

        private static Creative__c[] public_ads_from_DB() {
          return [Select Parent_Asset__c, Retired__c, Retirement_Reason__c
            From Creative__c
            Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
          }

        // private static Creative__c[] parents_from_DB() {
        //     return [Select Name__c, Retired__c, Retirement_Reason__c
        //             From Creative__c
        //             Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Parent Asset'];
        // }
}