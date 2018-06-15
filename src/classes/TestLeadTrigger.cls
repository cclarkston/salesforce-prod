@isTest
private class TestLeadTrigger {

//List<RecordType> rtypes1 = [Select Name, Id From RecordType
//                  		   where sObjectType='Campaign' and (DeveloperName='Seminar' or DeveloperName='Seminars') limit 1];

    testmethod static void test(){

    List<RecordType> rtypes = [Select Name, Id From RecordType
                  		   where sObjectType='Campaign' and (DeveloperName='Seminar' or DeveloperName='Seminars') limit 1];


    // Contact contact = new Contact();
    // Lead lead = new Lead();
    insert new Contact(LastName = 'User');
    insert new Lead(FirstName = 'Test', LastName = 'User', Street = '1313 Test Lane', City = 'Test City', State = 'AL', PostalCode = '01234-5678', Phone = '(123)456-7890', Date_of_Birth__c = Date.newInstance(2000, 1, 1));
    Contact contact = [select id FROM Contact limit 1];
    Lead lead = [select id, Call_Result__c FROM Lead WHERE  IsConverted =:false limit 1];

    Campaign camp = new Campaign();
    camp.name = 'test';
    camp.RecordTypeId = rtypes[0].id;
    insert camp;
    CampaignMember cmb = new CampaignMember();
    cmb.CampaignId  = camp.id;
    cmb.LeadId = lead.id;
    insert cmb;
    Test.startTest();
    lead.Call_Result__c = 'Consultation Scheduled';
    lead.DateTime_Consult_Scheduled__c = datetime.newInstance(2008, 12, 1, 10, 10, 10);
    lead.phone='1111111111';
    lead.Refused_to_give_email__c=true;
    update lead;

    lead.Status = 'Not Scheduled';
    lead.Call_Result__c = 'Same Day Cancellation Appointment';
    update lead;

    lead.Call_Result__c = 'Seminar Scheduled';
    update lead;
    lead.Call_Result__c = 'Same Day Cancellation Appointment';
    update lead;

    lead.Call_Result__c = 'Consult Scheduled';
    update lead;

    //seems redundant - cm 2012-2-1
    //lead.Call_Result__c = 'Same Day Cancellation Appointment';
    //update lead;

    //lead.Call_Result__c = 'Consult Scheduled';
    //update lead;

    lead.Call_Result__c = 'Cancelled Appointment';
    update lead;

    lead.Status = 'Consult Scheduled';
    lead.Call_Result__c = 'Same Day Rescheduled Consult';
    update lead;

    lead.Status = 'No Show';
    lead.Call_Result__c = 'Consultation Scheduled';
    update lead;
    Test.stopTest();


    //lead.Status = 'Rescheduled Consult';
    //lead.Call_Result__c = 'Consultation Scheduled';
    //update lead;

    /*
    lead.Call_Result__c = 'Consultation Scheduled';
    update lead;
    lead.Status = 'Same Day Cancellation';
    lead.Call_Result__c = 'Cancelled Appointment';
	update lead;

	lead.Status = 'Rescheduled Seminar';
	lead.Call_Result__c = 'Seminar Scheduled';
	update lead;

	lead.Status = 'Seminar Completed';
	lead.Call_Result__c = 'Off Site Seminar Scheduled';
	update lead;
	*/

    }

}