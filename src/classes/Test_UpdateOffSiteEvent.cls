/**
*********************************************************************************
Name    : Test_UpdateOffSiteEvent
Usage   : For the Lead object, this Trigger Updates the VIP_Event__c based on the Campaign Name;
            trigger fires on CampaignMember insert or update

CHANGE HISTORY
===============================================================================
DATE            NAME                  DESC
2011-05-17     Mike Merino            Initial release                
2012-06-25		 Chris McDowell					Commenting all of this out as the trigger is inactive.  This test just fails when we run all tests now

************************************************************************************
 */
@isTest
private class Test_UpdateOffSiteEvent {

    static testMethod void myUnitTest() {
/*      id usgId = userinfo.getUserId();
      Lead l1 = new Lead();
      Campaign c1 = new Campaign();
      CampaignMember cm1 = new CampaignMember();
      Campaign c2 = new Campaign();
      CampaignMember cm2 = new CampaignMember();
      for (user u:[select u.firstname, u.lastname, u.id from User u where u.id = :usgId limit 1])
      {
        l1.lastName =u.lastname;
        l1.firstName =u.firstname;
        l1.company=null; 
        l1.status ='Not Scheduled'; 
        l1.center__c = 'a0S40000002P7MeEAK'; //  Production Center ID
        insert l1;
        
        c1.Type = 'Advertisement';
        c1.Status ='Planned';
        c1.OwnerId = u.id;
        c1.Name = 'test campaign';
        insert c1;
        
        // after insert trigger call
        cm1.LeadId = l1.id;
        cm1.CampaignId = c1.id;
        insert cm1;
        
        List<CampaignMember> cm = [select id, CampaignId
                                from CampaignMember where LeadId = :cm1.LeadId];
        system.AssertEquals(cm.size(), 1);
       }*/
  }
}