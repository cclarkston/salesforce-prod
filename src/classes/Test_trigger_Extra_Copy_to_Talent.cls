/*
3/29/16
Triggers:
	Extra_after_insert_copy_to_Talent - 100%
*/

@isTest

private class Test_trigger_Extra_Copy_to_Talent {

  static testMethod void test_a_Talent_record_is_created_upon_insertion_of_an_Extra_record() {
    Test.startTest();
      Talent__c[] talents = [Select ID From Talent__c];
      Integer starting_talent_count = talents.size();

      insert new Extra__c(Name = 'Extra Name');
      Extra__c extra = [Select Name From Extra__c Where Name = 'Extra Name' Limit 1];
      talents = [Select Extra__c From Talent__c Order By CreatedDate DESC];

      System.assertEquals(starting_talent_count + 1, talents.size());
      System.assertEquals(extra.id, talents[0].Extra__c);
    Test.stopTest();
  }

}