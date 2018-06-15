/**
 * Created by Chris McDowell on 2/8/2012
 * Test Script for UpdateCampaignMemberStatus
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
private class Test_CampaignStatus {
  static testMethod void test_campaignmemberstatus() {
    try {
      list<Center_Information__c> denver_center = [Select Id From Center_Information__c  where name = 'Denver'];
	  list<User> test_user = [Select u.Name, u.LastName, u.Id, u.FirstName From User u where lastname = 'McDowell'];
	  Lead[] test_leads = new Lead[] { 
	    new Lead(Center__c = denver_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = test_user[0].id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Marketing_Source__c = '9445553467', Last_Marketing_Source__c = '9445553467', Status = 'Not Scheduled', OBJECTION__c = 'Hung Up'),
	    new Lead(Center__c = denver_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = test_user[0].id, LastName = 'Patient', FirstName = 'Test2', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Marketing_Source__c = '9175553412', Last_Marketing_Source__c = '9175553412', Status = 'Not Scheduled', OBJECTION__c = 'Hung Up'),
  	    new Lead(Center__c = denver_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = test_user[0].id, LastName = 'Patient 0', FirstName = 'Test2', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Marketing_Source__c = '9175553412', Last_Marketing_Source__c = '9175553412', Status = 'Not Scheduled', OBJECTION__c = 'Hung Up'),  
	    new Lead(Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = test_user[0].id, LastName = 'Unknown', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today()),
	    new Lead(Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = test_user[0].id, LastName = 'Doe', FirstName = 'John', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Marketing_Source__c = '9885556413', Last_Marketing_Source__c = ' ', Status = 'Not Scheduled',OBJECTION__c = 'Hung Up')
	  };
	  insert test_leads;
	  
	  list<Campaign> unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];	  
	  Campaign[] test_campaigns = new Campaign[] {
	  	new Campaign(Name = 'My Test Campaign', Center__c = denver_center[0].id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '9445553467', StartDate = Date.today()),
	    new Campaign(Name = 'My Test Campaign 2', Center__c = denver_center[0].id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '9175553412', StartDate = Date.today(),EndDate = Date.today().addDays(5)),
	    new Campaign(Name = 'My Test Future Campaign', Center__c = denver_center[0].id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '9885556413', StartDate = Date.today().addDays(20)),
	    new Campaign(Name = 'My Test Update', Center__c = denver_center[0].id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '', StartDate = Date.today())
	  };
	  Test.startTest();
	  insert test_campaigns;
	  
	  //verify statuses were created;
	  Integer ct = [select count() from CampaignMemberStatus where Campaignid =  :test_campaigns[0].id];
	  system.assert(ct==11);	  
	  
	  list <CampaignMember> cml = [select id,campaignid,leadid from CampaignMember where leadid in :test_leads];
	  Map<ID,Integer> lead_entries = new Map<ID,Integer> ();
	  for(Lead l : test_leads) {
	  	lead_entries.put(l.id,0);
	  }
	  system.debug('### Test Leads : ' + test_leads);
	  system.debug('### Test Campaigns : ' + test_campaigns);
	  
	  for(CampaignMember cm : cml) {
	  	//increment the counter
	  	system.debug('### CampaignID : ' + cm.campaignid + ' Lead Id : ' + cm.LeadId);
	  	lead_entries.put(cm.leadid,(lead_entries.get(cm.leadid) + 1));
	  	if(cm.leadid == test_leads[0].Id) 
          system.assert(cm.campaignid == test_campaigns[0].id);
        if(cm.leadid == test_leads[1].Id) 
          system.assert(cm.campaignid == test_campaigns[1].id);
        if(cm.leadid == test_leads[2].Id) 
          system.assert(cm.campaignid == test_campaigns[1].id);
        if(cm.leadid == test_leads[3].Id) 
          system.assert(cm.campaignid == unknown_campaign[0].id);
        if(cm.leadid == test_leads[4].Id) 
          system.assert(cm.campaignid == unknown_campaign[0].id);
	  }
	  //verifying the unknown campaign entries were cleaned up and all leads mapped to a single campaign
	  for(Lead l : test_leads) {
	  	system.assert(lead_entries.get(l.id)==1);
	  }	  
	  
	  //test udpate section
	  test_campaigns[3].Phone_Number__c = '9885556413';
	  update test_campaigns;
	  
	  cml = [select id,campaignid,leadid from CampaignMember where leadid in :test_leads];
	  lead_entries = new Map<ID,Integer> ();
	  for(Lead l : test_leads) {
	  	lead_entries.put(l.id,0);
	  }
	  for(CampaignMember cm : cml) {
	  	//increment the counter
	  	system.debug('### CampaignID : ' + cm.campaignid + ' Lead Id : ' + cm.LeadId);
	  	lead_entries.put(cm.leadid,(lead_entries.get(cm.leadid) + 1));
	  	if(cm.leadid == test_leads[0].Id) 
          system.assert(cm.campaignid == test_campaigns[0].id);
        if(cm.leadid == test_leads[1].Id) 
          system.assert(cm.campaignid == test_campaigns[1].id);
        if(cm.leadid == test_leads[2].Id) 
          system.assert(cm.campaignid == test_campaigns[1].id);
        if(cm.leadid == test_leads[3].Id) 
          system.assert(cm.campaignid == unknown_campaign[0].id);
        if(cm.leadid == test_leads[4].Id) 
          system.assert(cm.campaignid == unknown_campaign[3].id);
	  }
	  //verifying the unknown campaign entries were cleaned up and all leads mapped to a single campaign
	  for(Lead l : test_leads) {
	  	system.assert(lead_entries.get(l.id)==1);
	  }
	  	  
	  Test.stopTest();
      	  	
    }  catch(Exception e) {    system.debug ('error: ' + e.getMessage() );    }   
  }
}