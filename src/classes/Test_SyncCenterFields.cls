/**********************************************************************************
Name    : Test_SyncCenterFields
Usage   : For the Account object, this Trigger Updates the Center_Location__c from Account.Center__r.Name.

CHANGE HISTORY
===============================================================================
DATE            NAME                  DESC
2011-04-05     Jason Taylor            Initial release                

*************************************************************************************/
@isTest
private class Test_SyncCenterFields {
    testMethod static void testIt() {

        Account a1 = new Account();
        id usgId = userinfo.getUserId();
        // user setup due to 
        //    lead validation rule: Validate_that_Call_Center_Agent_Current
        //    lead custom field Call Center Agent (Lookup);validation rule: Validate_that_Call_Center_Agent_Current
for (user u:[select u.firstname, u.lastname, u.id from User u where u.id = :usgId limit 1])
{
        String Lname = u.LastName;
        String Fname =u.firstname; 
  //      system.debug('### '+usgId+'--'+lname);
        a1.LastName =Lname;
        a1.firstName =Fname;
    //    system.debug('### '+l1);
        a1.Center_location__c='Tucson'; 
    //    l1.status ='Not Scheduled'; 
    //    a1.Call_Center_Agent__c = u.Id; //call_ctr_agent must = usgId
    //    a1.center__c = 'a0S40000002P7MEEA0'; //  atlanta
        a1.consult_result__c = '2nd Consult';
        a1.Preliminary_Treatment_Plan__c = 'Single Implant';
        a1.Preliminary_Treatment_Fee_Quoted__c = 5000;
        a1.Financing_Result__c = 'Declined';
        a1.RecordTypeId = '012400000009EvTAAU';
        a1.Call_Center_Owner__c = 'Jason Taylor';
        
        insert a1;
        system.debug('### Test_SyncCenterFields '+a1);
}
}
}