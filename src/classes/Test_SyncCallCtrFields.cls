/**********************************************************************************
Name    : Test_SyncCallCtrFields
Usage   : For the Lead object, this Trigger Updates the Call_Center_Agent_Owner__c based on the Call_Center_Agent__r.Name
                                                    and Center_Location__c from Lead.Center__r.Name.

CHANGE HISTORY
===============================================================================
DATE            NAME                  DESC
2011-03-07     Mike Merino            Initial release      
2011-09-09		Seth Davidow		  Update to remove Id dependencies           

*************************************************************************************/
@isTest
private class Test_SyncCallCtrFields {
    testMethod static void testIt() {
return;  //sjd tmp
        Lead l1 = new Lead();
        id usgId = userinfo.getUserId();
		Center_Information__c center = [select id from Center_Information__c limit 1];

        // user setup due to 
        //    lead validation rule: Validate_that_Call_Center_Agent_Current
        //    lead custom field Call Center Agent (Lookup);validation rule: Validate_that_Call_Center_Agent_Current
for (user u:[select u.firstname, u.lastname, u.id from User u where u.id = :usgId limit 1])
{
        String Lname = u.LastName;
        String Fname =u.firstname; 
  //      system.debug('### '+usgId+'--'+lname);
        l1.lastName =lname;
        l1.firstName =fname;
    //    system.debug('### '+l1);
        l1.company=null; 
        l1.status ='Not Scheduled'; 
        l1.Call_Center_Agent__c = u.Id; //call_ctr_agent must = usgId
        l1.center__c = center.id; //'a0S40000002P7MnEAK'; //  atlanta
        
        insert l1;
        system.debug('### Test_SyncCallCtrFields '+l1);
    
 // now test WelcomePkgSent trigger    , whoId must be Lead.id
// set email flag in lead
List<task> t = new List<task>{ new task(
        WhoId = l1.Id,
       // WhatID = l1.id,
        Subject='this is Email: myTest',
        Status='New',
        Priority='Normal')};

        insert t; 
        system.debug('### Test_SyncCallCtrFields Task t='+t); 
        
        List<task> taskstoupdate = New List<task>{ [select id from task where id in :t]};
             for(task tOK:taskstoupdate)
             {
                 tOK.status = 'Completed';

                 Update taskstoupdate;
             }
// set welcome flag in lead             
        List<task> t1 = new List<task>{ new task(
        WhoId = l1.Id,
       // WhatID = l1.id,
        Subject='You are Welcome',
        Status='New',
        Priority='Normal')};

        insert t1; 
        system.debug('### Task Test_SyncCallCtrFields t1='+t1); 

        List<task> taskstoupdate1 = New List<task>{ [select id from task where id in :t1]};
             for(task tOK:taskstoupdate)
             {
                 tOK.status = 'Active';

                 Update taskstoupdate1;
             }
       //  flags already set in lead
        List<task> taskstoupdate2 = New List<task>{ [select id from task where id in :t1]};
             for(task tOK:taskstoupdate)
             {
                 tOK.Priority = 'Completed';

                 Update taskstoupdate2;
             }             
       }   
    }
 }