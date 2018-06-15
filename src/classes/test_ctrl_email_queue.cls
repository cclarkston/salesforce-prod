@isTest
private class test_ctrl_email_queue {
  
  static testMethod void myTest() {
  	Market__c m = new Market__c(Name = 'Test Market');
  	insert m;
		Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center;							
		Profile p = [select id from Profile where name = 'System Administrator'];		
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
	  Campaign c = new Campaign(Name = 'Test Campaign',type = 'Retirement Center Seminar', startdate = System.today(),time__c = '7:00 AM');
	  insert c;		
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up', email='test@clearchoice.com');
    insert test_lead;		  
    CampaignMember cm = new CampaignMember(CampaignId = c.id, LeadId = test_lead.id);
    insert cm;
  	Email_Queue__c eq = new Email_Queue__c(Template_Name__c = 'Seminar_VF', target_id__c = test_lead.id, seminar_id__c = c.id);
  	insert eq;
  	Test.startTest();
  	Ctrl_Email_Queue.send_email_queue();  	  	
  	test.stopTest();
  }    
    
}