/*
05/22/2018  CC  Inital commit
05/24/2018  CC  Changed test to test for status message on opt out
05/31/2018  CC  Changed tests for match new logic stating that we should only send messages to people that have opt in
06/05/2018  CC  Added assert statements to make sure the Account and Lead reference are updated
06/09/2018  CC  Added test for multiple sms insert;
06/11/2018  CC  Added check on Reminder_Text__c 
*/

@isTest 
public class SMSBeforeInsertTests {
    @testSetup static void CreateTestSMSSenderIds() {
        List<Lead> leads = new List<Lead>();
        //Create lead 
        Lead lead = TestDataFactory.CreateTestLead();
        lead.phone = '(303) 321-4567';
        leads.add(lead);
        TestDataFactory.CreateSendIds();
        //Create lead opt out
        lead = TestDataFactory.CreateTestLead();
        lead.phone = '(303) 321-4561';
        lead.smagicinteract__SMSOptOut__c = true;
        leads.add(lead);
        //Create lead opt in
        lead = TestDataFactory.CreateTestLead();
        lead.phone = '(303) 321-4562';
        lead.Receive_Text_Reminder__c = true;
        leads.add(lead);
        lead = TestDataFactory.CreateTestLead();
        lead.phone = '(303) 321-4564';
        lead.Reminder_Text__c = Constants.TextReminderTrue;
        leads.add(lead);
        insert leads;
        List<Account> accounts = new List<Account>();
        //Create account
        Account account = TestDataFactory.CreateTestAccount();
        account.phone = '(303) 987-2314';
        accounts.add(account);
        //Create account opt out
        account = TestDataFactory.CreateTestAccount();
        account.phone = '(303) 987-2319';
        account.Receive_Text_Reminder__c = true;
        account.smagicinteract__SMSOptOut__pc = true;
        accounts.add(account);
        //Create account opt in
        account = TestDataFactory.CreateTestAccount();
        account.Receive_Text_Reminder__c = true;
        account.phone = '(303) 987-2310';
        accounts.add(account);
        account = TestDataFactory.CreateTestAccount();
        account.Reminder_Text__c = Constants.TextReminderTrue;
        account.phone = '(303) 987-2311';
        accounts.add(account);
        insert accounts;
    }

    private static smagicinteract__SMS_SenderId__c getSenderId(String senderId) {
        smagicinteract__SMS_SenderId__c sender = [SELECT Id, smagicinteract__senderId__c 
                                                            FROM smagicinteract__SMS_SenderId__c
                                                            WHERE smagicinteract__senderId__c = :senderId 
                                                            LIMIT 1];
        return sender;
    }

    private static smagicinteract__smsMagic__c getSMS() {
        smagicinteract__smsMagic__c sms = [SELECT Lead__c , Account__c, smagicinteract__sentStatus__c, smagicinteract__Lead__c, smagicinteract__Account__c
                                            FROM smagicinteract__smsMagic__c
                                            LIMIT 1];
        return sms;                                    
    }

    private static List<Task> getTask() {
        List<Task> tasks = [SELECT Activity_Type__c, Outcome__c
                    FROM task];
        return tasks;            
    }

    @isTest static void EventIsCreateOnSMSHistoryCreatedAndMatchLeadAndHasSMSType() {
        Lead lead = [SELECT Id
                        FROM Lead
                        Where phone = '(303) 321-4567'
                        LIMIT 1];          
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3033214567';
        sms.smagicinteract__senderId__c = getSenderId('1').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;
        Test.stopTest();
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);
        sms = getSMS();
        System.assert(sms.Lead__c == lead.Id); 
        System.assert(sms.smagicinteract__Lead__c == lead.Id);     
        System.assert(tasks[0].Activity_Type__c == Constants.ManualOutgoingSMSActivityType);      
        System.assert(tasks[0].Outcome__c == Constants.MessageNotSentNotOptIn);                  
    }

    @isTest static void EventIsCreateOnSMSHistoryCreatedAndMatchAccountAndHasSMSType() {
        Account account = [SELECT Id
                        FROM Account
                        WHERE Phone = '(303) 987-2314'
                        LIMIT 1];
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3039872314';
        sms.smagicinteract__senderId__c = getSenderId('1').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;      
        Test.stopTest(); 
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);   
        sms = getSMS();    
        System.assert(sms.Account__c == account.Id); 
        System.assert(sms.smagicinteract__Account__c == account.Id);  
        System.assert(tasks[0].Activity_Type__c == Constants.ManualOutgoingSMSActivityType); 
        System.assert(tasks[0].Outcome__c == Constants.MessageNotSentNotOptIn);                          
    }

    @isTest static void EventIsCreateOnSMSHistoryCreatedAndMatchLeadAndHasOnlineType() {
        Lead lead = [SELECT Id
                        FROM Lead
                        WHERE Phone = '(303) 321-4567'
                        LIMIT 1];          
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3033214567';
        sms.smagicinteract__senderId__c = getSenderId('2').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;
        Test.stopTest();
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);
        sms = getSMS();    
        System.assert(sms.Lead__c == lead.Id);  
        System.assert(sms.smagicinteract__Lead__c == lead.Id);     
        System.assert(tasks[0].Activity_Type__c == Constants.OnlineOutgoingSMSActivityType); 
        System.assert(tasks[0].Outcome__c == Constants.MessageNotSentNotOptIn);                    
    }

    @isTest static void EventIsCreateOnSMSHistoryCreatedAndMatchAccountAndHasOnlineType() {
        Account account = [SELECT Id
                        FROM Account
                        WHERE phone = '(303) 987-2314'
                        LIMIT 1];
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3039872314';
        sms.smagicinteract__senderId__c = getSenderId('2').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;      
        Test.stopTest();    
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);
        sms = getSMS();           
        System.assert(sms.Account__c == account.Id);  
        System.assert(sms.smagicinteract__Account__c == account.Id);  
        System.assert(tasks[0].Activity_Type__c == Constants.OnlineOutgoingSMSActivityType);   
        System.assert(tasks[0].Outcome__c == Constants.MessageNotSentNotOptIn);                        
    } 

  @isTest static void SMSANDTaskShowAccountOptInCheckText() {
        Account account = [SELECT Id
                        FROM Account
                        WHERE phone = '(303) 987-2311'
                        LIMIT 1];
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3039872311';
        sms.smagicinteract__senderId__c = getSenderId('1').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;     
        Test.stopTest();  
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);   
        sms = getSMS();             
        System.assert(sms.Account__c == account.Id); 
        System.assert(sms.smagicinteract__Account__c == account.Id);          
        System.assert(sms.smagicinteract__sentStatus__c != Constants.MessageNotSentNotOptIn);
  }

  @isTest static void SMSANDTaskShowAccountOptIn() {
        Account account = [SELECT Id
                        FROM Account
                        WHERE phone = '(303) 987-2310'
                        LIMIT 1];
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3039872310';
        sms.smagicinteract__senderId__c = getSenderId('1').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;     
        Test.stopTest();  
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);   
        sms = getSMS();             
        System.assert(sms.Account__c == account.Id); 
        System.assert(sms.smagicinteract__Account__c == account.Id);          
        System.assert(sms.smagicinteract__sentStatus__c != Constants.MessageNotSentNotOptIn);
  }

  @isTest static void SMSANDTaskShowLeadOptInCheckText() {
        Lead lead = [SELECT Id
                        FROM Lead
                        WHERE phone = '(303) 321-4564'
                        LIMIT 1];
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3033214564';
        sms.smagicinteract__senderId__c = getSenderId('1').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;     
        Test.stopTest();  
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);   
        sms = getSMS();             
        System.assert(sms.Lead__c == lead.Id); 
        System.assert(sms.smagicinteract__Lead__c == lead.Id);          
        System.assert(sms.smagicinteract__sentStatus__c != Constants.MessageNotSentNotOptIn);
  }

  @isTest static void SMSANDTaskShowLeadOptIn() {
        Lead lead = [SELECT Id
                        FROM Lead
                        WHERE phone = '(303) 321-4562'
                        LIMIT 1];
        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
        sms.smagicinteract__PhoneNumber__c ='3033214562';
        sms.smagicinteract__senderId__c = getSenderId('1').smagicinteract__senderId__c;
        Test.startTest();
        insert sms;     
        Test.stopTest();  
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 1);   
        sms = getSMS();             
        System.assert(sms.Lead__c == lead.Id); 
        System.assert(sms.smagicinteract__Lead__c == lead.Id);          
        System.assert(sms.smagicinteract__sentStatus__c != Constants.MessageNotSentNotOptIn);
  }  

  @isTest static void SMSANDTaskShowAccountOptInMultiple() {
        Account account = [SELECT Id
                        FROM Account
                        WHERE phone = '(303) 987-2310'
                        LIMIT 1];
        String senderId = getSenderId('1').smagicinteract__senderId__c;
        List<smagicinteract__smsMagic__c> smsList = new List<smagicinteract__smsMagic__c>();
        for(Integer x = 0; x < 100; x++) {
            smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
            sms.smagicinteract__PhoneNumber__c ='3039872310';
            sms.smagicinteract__senderId__c = senderId;
            smsList.add(sms);
        }
        Test.startTest();
        insert smsList;     
        Test.stopTest();  
        List<Task> tasks = getTask();
        System.assert(tasks.size() == 100);   
  }
}