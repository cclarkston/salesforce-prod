/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class test_crnLinkInContacttoLead {

     static testMethod void testRunCrnLinkInContacttoLeads(){
         test.startTest();
    
         Util_TriggerContext.setalreadyProcessed();
    
         crnLinkInContacttoLeads API = new crnLinkInContacttoLeads();
    
         List<InContact__c> myContacts = new List<InContact__c>();
         myContacts.add(new InContact__c(
             MasterContactID__c = 123456789,
             From__c = '5551234567',
             To__c = '8881234567',
             OutboundSkill__c = false,
             StartDate__c = datetime.now(),
             EndDate__c = datetime.now().addHours(1)
         ));
         myContacts.add(new InContact__c(
             MasterContactID__c = 987654321,
             From__c = '5559876543',
             To__c = '8881234567',
             OutboundSkill__c = false,
             StartDate__c = datetime.now(),
             EndDate__c = datetime.now().addHours(1)
         ));
         myContacts.add(new InContact__c(
             MasterContactID__c = 654987321,
             From__c = '5554561237',
             To__c = '8881234567',
             OutboundSkill__c = false,
             StartDate__c = datetime.now(),
             EndDate__c = datetime.now().addHours(1)
         ));
         myContacts.add(new InContact__c(
             MasterContactID__c = 789456123,
             From__c = '5557894561',
             To__c = '8881234567',
             OutboundSkill__c = false,
             StartDate__c = datetime.now(),
             EndDate__c = datetime.now().addHours(1)
         ));
         myContacts.add(new InContact__c(
             MasterContactID__c = 456789123,
             From__c = '5557894561',
             To__c = '8881234567',
             OutboundSkill__c = false,
             StartDate__c = NULL,
             EndDate__c = datetime.now().addHours(1)
         ));
         myContacts.add(new InContact__c(
             MasterContactID__c = 456123789,
             To__c = '8529637410',
             From__c = '8881234567',
             OutboundSkill__c = true,
             StartDate__c = NULL,
             EndDate__c = NULL
         ));
    
         Util_TriggerContext.setalreadyProcessed();
         insert myContacts;
    
         Campaign myCampaign = new Campaign(Name = 'Test Campaign', Phone_Number__c = '8881234567');
         insert myCampaign;
    
         Center_Information__c myCenter = new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
         insert myCenter;
    
         List<Lead> myLeads = new List<Lead>();
    
         myLeads.add(new Lead(
             FirstName = 'Test',
             LastName = 'InContact',
             center__c = myCenter.Id, Center_Location__c = 'Denver',
             Phone='5551234567',
             Original_Phone__c ='5551234567',
             Refused_to_give_email__c=true
         ));
    
         myLeads.add(new Lead(
             FirstName = 'Test',
             LastName = 'InContact 2',
             center__c = myCenter.Id, Center_Location__c = 'Denver',
             Phone='5559876543',
             Original_Phone__c ='5559876543',
             Refused_to_give_email__c = true
         ));
    
         myLeads.add(new Lead(
             FirstName = 'Test',
             LastName = 'InContact 3',
             center__c = myCenter.Id, Center_Location__c = 'Denver',
             Phone='5554561237',
             Original_Phone__c ='5554561237',
             Refused_to_give_email__c=true
         ));
    
         myLeads.add(new Lead(
             FirstName = 'Test',
             LastName = 'InContact 4',
             center__c = myCenter.Id, Center_Location__c = 'Denver',
             Phone='5557894561',
             Original_Phone__c ='5557894561',
             Refused_to_give_email__c=true
         ));
    
         myLeads.add(new Lead(
             FirstName = 'Test',
             LastName = 'InContact 5',
             center__c = myCenter.Id, Center_Location__c = 'Denver',
             Phone='1470258369',
             Original_Phone__c ='8529637410',
             Refused_to_give_email__c=true
         ));
    
         Util_TriggerContext.setalreadyProcessed();
         insert myLeads;
    
         Database.LeadConvert lc = new database.LeadConvert();
	 	lc.setLeadId(myLeads[1].Id);
	 	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
	 	lc.setConvertedStatus(convertStatus.MasterLabel);
	 	Database.LeadConvertResult lcr = Database.convertLead(lc);
	 	System.assert(lcr.isSuccess());
    
         Database.LeadConvert lc2 = new database.LeadConvert();
	 	lc2.setLeadId(myLeads[2].Id);
	 	LeadStatus convertStatus2 = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
	 	lc2.setConvertedStatus(convertStatus2.MasterLabel);
	 	Database.LeadConvertResult lcr2 = Database.convertLead(lc2);
	 	System.assert(lcr2.isSuccess());
	
         List<Task> myTask = new List<Task>();
         myTask.add(new Task(
             WhoId = myLeads[0].Id,
             Type = 'Call',
             CallObject = '123456789',
             Status = 'Completed',
             Priority = 'Normal',
             CallType = 'Inbound',
             CallDurationInSeconds = 100
         ));
         Util_TriggerContext.setalreadyProcessed();
         insert myTask;
    
         List<CampaignMember> myCampaignMember = new List<CampaignMember>();
         myCampaignMember.add(new CampaignMember(
             LeadId  = myLeads[3].Id,
             CampaignId = myCampaign.Id,
             Status = 'Responded',
             DevNotes__c = 'crnLinkInContacttoLeads'
         ));
         myCampaignMember.add(new CampaignMember(
             LeadId  = myLeads[4].Id,
             CampaignId = myCampaign.Id,
             Status = 'Responded',
             DevNotes__c = 'crnLinkInContacttoLeads'
         ));
         /*
         myCampaignMember.add(new CampaignMember(
             ContactId = myLeads[2].ConvertedContactId,
             CampaignId = myCampaign.Id,
             Status = 'Responded',
             DevNotes__c = 'crnLinkInContacttoLeads'
         ));
         */
         Util_TriggerContext.setalreadyProcessed();
         insert myCampaignMember;
    
     	API.crnLinkInContacttoLeads();
    
         test.stopTest();
     }
}