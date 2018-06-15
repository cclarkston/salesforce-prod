/**
 * Created by Chris McDowell on 1/12/2012
 * Test Script for WelcomePktSent.trigger 
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
private class TestWelcomePacket {

    static testMethod void testTaskCreation() {
      try {
      	list<Center_Information__c> denver_center = [Select Id From Center_Information__c  where name = 'Denver'];
    	User test_user = [select id from user where Call_Center_Team__c = 'Confirmation' limit 1];
    	
    	Campaign[] test_campaigns = new Campaign[] {
	  	  new Campaign(Name = 'My Test Campaign', Center__c = denver_center[0].id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '5555551113', StartDate = Date.today())
	    };
	    insert test_campaigns;
	    Date my_date = date.today();
	    my_date = my_date.addDays(7);
	    Datetime test_date = datetime.newInstance(my_date.year(),my_date.month(),my_date.day(),18,30,0);
    	
       //create a lead record to work with
	    Lead[] test_leads = new Lead[] { 
	      new Lead(Center__c = denver_center[0].id,Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	        Call_Center_Agent__c = test_user.id, LastName = 'Unknown', FirstName = 'Test', Gender__c = 'Male',
	        Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date),
	      new Lead(Center__c = denver_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	        Call_Center_Agent__c = test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male', City = 'lower test',
	        Call_Result__c = 'Not Scheduled', Marketing_Source__c = '5555551113', Last_Marketing_Source__c = '', Status = 'Not Scheduled', OBJECTION__c = 'Hung Up'),
   	      new Lead(Center__c = denver_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	        Call_Center_Agent__c = test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	        Call_Result__c = 'Not Scheduled', Marketing_Source__c = '5555551113', Last_Marketing_Source__c = '', Status = 'Not Scheduled', OBJECTION__c = 'Hung Up'),
	      new Lead(Center__c = denver_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	        Call_Center_Agent__c = test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	        Call_Result__c = 'Not Scheduled', Marketing_Source__c = '5555551113', Last_Marketing_Source__c = '', Status = 'Not Scheduled', OBJECTION__c = 'Hung Up'),
   	      new Lead(Center__c = denver_center[0].id,Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	        Call_Center_Agent__c = test_user.id, LastName = 'Unknown', FirstName = 'Test', Gender__c = 'Male',
	        Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date),
   	      new Lead(Center__c = denver_center[0].id,Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	        Call_Center_Agent__c = test_user.id, LastName = 'Unknown', FirstName = 'Test', Gender__c = 'Male',
	        Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date)	        
	    };
	    insert test_leads;	   
	    	    
	    Task[] test_tasks = new Task[] {
	      new Task(WhoId = test_leads[0].Id, OwnerId = test_user.Id, Subject = 'BCP Letter', Type = 'Other', Activity_Type__c = 'Outbound Email', Outcome__c = 'Sent'),
	      new Task(WhoId = test_leads[0].Id, OwnerId = test_user.Id, Subject = 'Welcome', Type = 'Other', Activity_Type__c = 'Outbound Email', Outcome__c = 'Sent'),
	      new Task(WhoId = test_leads[0].Id, OwnerId = test_user.Id, Subject = 'Email: ClearChoice Dental Implant Consultation', Type = 'Other', Activity_Type__c = 'Outbound Email', Outcome__c = 'Sent'),
	      new Task(WhoId = test_leads[0].Id, OwnerId = test_user.Id, Subject = 'Welcome', Type = 'Other', Activity_Type__c = 'Outbound Call', Outcome__c = 'Seminar Confirmed'),
	      new Task(WhoId = test_leads[1].Id, OwnerId = test_user.Id, Subject = 'NA', Type = 'Other', Activity_Type__c = 'Outbound Call', Outcome__c = 'Busy/No Answer'),
	      new Task(WhoId = test_leads[2].Id, OwnerId = test_user.Id, Subject = 'NA', Type = 'Other', Activity_Type__c = 'Outbound Call', Outcome__c = 'VM - LM'),
	      new Task(WhoId = test_leads[3].Id, OwnerId = test_user.Id, Subject = 'NA', Type = 'Other', Activity_Type__c = 'Outbound Call', Outcome__c = 'Consult Cancelled'),
	      new Task(WhoId = test_leads[4].Id, OwnerId = test_user.Id, Subject = 'NA', Type = 'Other', Activity_Type__c = 'Inbound Call', Outcome__c = 'Consult Cancelled'),
	      new Task(WhoId = test_leads[5].Id, OwnerId = test_user.Id, Subject = 'NA', Type = 'Other', Activity_Type__c = 'Inbound Call', Outcome__c = 'Consult Confirmed')      	     
	    };
	    
	    Test.startTest();
	    system.debug('### Inserting Tasks');
	    insert test_tasks;
	    
	    //check to make sure lead record had checkboxes marked
	    Lead my_test_lead = [select 
	      id,
	      BCP_DVD_Packet_Sent__c,
	      Email_Welcome_Packet_Sent__c,
	      Welcome_Packet_Sent__c,
	      Confirmed_Appointment__c,
	      Could_not_Reach__c,
	      Left_Message_to_Confirm__c
	    from Lead where id = :test_leads[0].Id];
	    system.assert(my_test_lead.BCP_DVD_Packet_Sent__c == true);
	    system.assert(my_test_lead.Email_Welcome_Packet_Sent__c == true);
	    system.assert(my_test_lead.Welcome_Packet_Sent__c  == true); 
	    system.assert(my_test_lead.Confirmed_Appointment__c == true);
	    system.assert(my_test_lead.Could_not_Reach__c == false);
	    system.assert(my_test_lead.Left_Message_to_Confirm__c == false);
	    my_test_lead = [select 
	      id,
	      BCP_DVD_Packet_Sent__c,
	      Email_Welcome_Packet_Sent__c,
	      Welcome_Packet_Sent__c,
	      Confirmed_Appointment__c,
	      Could_not_Reach__c,
	      Left_Message_to_Confirm__c
	    from Lead where id = :test_leads[1].Id];
	    system.assert(my_test_lead.Confirmed_Appointment__c == false);
	    system.assert(my_test_lead.Could_not_Reach__c == true);
	    system.assert(my_test_lead.Left_Message_to_Confirm__c == false);
	    my_test_lead = [select 
	      id,
	      BCP_DVD_Packet_Sent__c,
	      Email_Welcome_Packet_Sent__c,
	      Welcome_Packet_Sent__c,
	      Confirmed_Appointment__c,
	      Could_not_Reach__c,
	      Left_Message_to_Confirm__c
	    from Lead where id = :test_leads[2].Id]; 
	    system.assert(my_test_lead.Confirmed_Appointment__c == false);
	    system.assert(my_test_lead.Could_not_Reach__c == false);
	    system.assert(my_test_lead.Left_Message_to_Confirm__c == true);
	    
	    Test.stopTest();
	  } catch(Exception e) {    system.debug ('error: ' + e.getMessage() );    }
    }
}