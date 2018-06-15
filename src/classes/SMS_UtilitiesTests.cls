/*
05/25/2018  CC  Inital commit
05/29/2018  CC   Added tests for GetOptOutLeadsByPhoneNumber/GetOutedOutAccountsByPhoneNumber
05/31/2038  CC  Added test for GetOptInLeadsByPhoneNumber/GetOptInAccountsByPhoneNumber 
06/05/2018  CC  Added test for SyncAccountAndLead
06/11/2018  CC  Added test for Reminder_Text__c check
*/

@isTest
private class SMS_UtilitiesTests {

    static testMethod void BulkSMSTest() {
        Set<String> phones = new Set<String>{'1234567890', '0987654321'};
        String message     = 'Testing bulk messages.';
        String sender      = 'The Management';
        system.assert(SMS_Utilities.send_bulk_sms(phones, message, sender).contains('<vstatus>success</vstatus>'));
    }
  
  @testSetup static void createLeads() {
    Util_TriggerContext.alteralreadyprocessed(true);
    TestDataFactory.CreateSendIds();
    List<Lead> leads = new List<Lead>();
    for(Integer counter = 1; counter < 10; counter++) {
      Lead lead = TestDataFactory.CreateTestLead();
      if (counter == 1) {
        lead.LastName = 'Test Lead';
        lead.Phone = '(303) 321-1234';
      }
      if (counter == 2) {
        lead.LastName = 'Test Lead 2';
        lead.Phone = '(303) 321-1235';
        lead.smagicinteract__SMSOptOut__c = true;
      }  
      if (counter == 3) {
        lead.LastName = 'Test Lead';
        lead.MobilePhone = '(303) 111-1234';
      }
      if (counter == 4) {
        lead.LastName = 'Test Lead 2';
        lead.MobilePhone = '(303) 111-1235';
      }  
      if (counter == 5) {
        lead.Phone = '(303) 666-1233';
        lead.smagicinteract__SMSOptOut__c=false;
        lead.Receive_Text_Reminder__c = true;
      }  
      if (counter == 6) {
        lead.Phone = '(303) 666-1133';
        lead.smagicinteract__SMSOptOut__c=true;
        lead.Receive_Text_Reminder__c = true;
      }    
      if (counter == 7) {
        lead.Phone = '(303) 666-1137';
        lead.Reminder_Text__c = Constants.TextReminderTrue;
      }   
      leads.add(lead);
    }
    insert leads;
    List<Account> accounts = new List<Account>();
    for(Integer counter = 1; counter < 10; counter++) {
      Account account = TestDataFactory.CreateTestAccount();
      if(counter == 1) {
        account.LastName = 'Test Account';
        account.Phone = '(303) 321-1234';
      }
      if(counter == 2) {
        account.LastName = 'Test Account 2';
        account.Phone = '(303) 321-1235';
        account.smagicinteract__SMSOptOut__pc = true;
      }
      //opt in accounts
      if(counter == 3) {
        account.Phone = '(303) 321-1233';
        account.smagicinteract__SMSOptOut__pc = true;
        account.Receive_Text_Reminder__c = false;
      }  
      if(counter == 4) {
        account.Phone = '(303) 321-1232';
        account.smagicinteract__SMSOptOut__pc = false;
        account.Receive_Text_Reminder__c = true;
      }  
      //text reminder yes, but have also opt out
      if(counter == 5) {
        account.Phone = '(303) 321-1231';
        account.smagicinteract__SMSOptOut__pc = true;
        account.Receive_Text_Reminder__c = true;
      }  
      if(counter == 6) {
        account.PersonMobilePhone = '(303) 555-1232';
        account.smagicinteract__SMSOptOut__pc = false;
        account.Receive_Text_Reminder__c = true;
      }  
      //text reminder yes, but have also opt out
      if(counter == 7) {
        account.PersonMobilePhone = '(303) 555-1231';
        account.smagicinteract__SMSOptOut__pc = true;
        account.Receive_Text_Reminder__c = true;
      } 
	  if(counter == 8) {
        account.PersonMobilePhone = '(303) 555-1237';
        account.Reminder_Text__c = Constants.TextReminderTrue;
      } 
      accounts.add(account);
    }
    insert accounts;
    accounts = [SELECT LastModifiedDate FROM Account];
    smagicinteract__SMS_Template__c template = new smagicinteract__SMS_Template__c();
    template.smagicinteract__Name__c = 'templatename';
    insert template;
  }

  static testMethod void GetLeadsByPhoneNumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 321-1234');
    Map<String, Lead> leads = SMS_Utilities.GetLeadsByPhoneNumber(phones);
    System.Assert(leads.size() == 1);
    Lead lead = leads.get('(303) 321-1234');
    System.Assert(lead.LastName == 'Test Lead');
  }

  static testMethod void GetLeadsByMobilePhoneNumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 111-1234');
    Map<String, Lead> leads = SMS_Utilities.GetLeadsByPhoneNumber(phones);
    System.Assert(leads.size() == 1);
    Lead lead = leads.get('(303) 111-1234');
    System.Assert(lead.LastName == 'Test Lead');
  }  

  static testMethod void GetAccountsByPhoneNumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 321-1234');
    Map<String, Account> accounts = SMS_Utilities.GetAccountsByPhoneNumber(phones);
    System.Assert(accounts.size() == 1);
    Account account = accounts.get('(303) 321-1234');
    System.Assert(account.LastName == 'Test Account');
  }  

  static testMethod void GetOptOutLeadsByPhoneNumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 321-1235');
    Map<String, Lead> leads = SMS_Utilities.GetOptOutLeadsByPhoneNumber(phones);
    System.Assert(leads.size() == 1);
    Lead lead = leads.get('(303) 321-1235');
    System.Assert(lead.LastName == 'Test Lead 2');
  }

  static testMethod void GetOptOutAccountsByPhoneNumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 321-1235');
    Map<String, Account> accounts = SMS_Utilities.GetOptOutAccountsByPhoneNumber(phones);
    System.Assert(accounts.size() == 1);
    Account account = accounts.get('(303) 321-1235');
    System.Assert(account.LastName == 'Test Account 2');
  }  

  static testMethod void GetOptInLeadByPhonenumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 666-1233');
    phones.add('(303) 666-1133');
	phones.add('(303) 666-1137');
    Map<String, Lead> leads = SMS_Utilities.GetOptInLeadsByPhoneNumber(phones);
    System.Assert(leads.size() == 2);
  }  

  static testMethod void GetOptInAccountByPhonenumber() {
    Set<String> phones = new Set<String>();
    phones.add('(303) 321-1233');
    phones.add('(303) 321-1232');
	phones.add('(303) 555-1237');
    Map<String, Account> accounts = SMS_Utilities.GetOptInAccountsByPhoneNumber(phones);
    System.Assert(accounts.size() == 2);
  }

  static testMethod void CreateTaskForSMSAccount() {
    Account account = [SELECT ID 
              FROM Account 
              WHERE Phone = '(303) 321-1235'
              LIMIT 1];
    smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
    sms.smagicinteract__PhoneNumber__c ='3033211235';
    sms.Account__c = account.Id;
    sms.smagicinteract__senderId__c = '1';
    insert sms;
    Task task = SMS_Utilities.CreateTaskForSMS(sms);
    System.Assert(task != null);    
    System.Assert(task.Activity_Type__c == Constants.ManualOutgoingSMSActivityType);
    System.Assert(task.WhatId == account.Id);
  } 

  static testMethod void CreateTaskForSMSLead() {
    Lead lead = [SELECT ID 
            FROM Lead 
            WHERE Phone = '(303) 321-1234'
              LIMIT 1];
    smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
    sms.smagicinteract__PhoneNumber__c ='30393211234';
    sms.Lead__c = lead.Id;
    sms.smagicinteract__senderId__c = '1';
    insert sms;
    Task task = SMS_Utilities.CreateTaskForSMS(sms);
    System.Assert(task != null);    
    System.Assert(task.Activity_Type__c == Constants.ManualOutgoingSMSActivityType);
    System.Assert(task.WhoId == lead.Id);
  } 

  static testMethod void SyncAccountAndLeadTest() {
    String testId1 = '11Q4000000UzOE6';
    String testId2 = '22Q4000000UzOE6';
    smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
    sms.Account__c = testId1;
    sms = SMS_Utilities.SyncAccountAndLead(sms);
    System.assert(String.valueof(sms.smagicinteract__Account__c).left(15) == testId1); 
    sms = new smagicinteract__smsMagic__c();
    sms.smagicinteract__Account__c = testId2;
    sms = SMS_Utilities.SyncAccountAndLead(sms);
    System.assert(String.valueof(sms.Account__c).left(15) == testId2);
    sms = new smagicinteract__smsMagic__c();
    sms.Lead__c = testId1;
    sms = SMS_Utilities.SyncAccountAndLead(sms);
    System.assert(String.valueof(sms.smagicinteract__Lead__c).left(15) == testId1); 
    sms = new smagicinteract__smsMagic__c();
    sms.smagicinteract__Lead__c = testId2;
    sms = SMS_Utilities.SyncAccountAndLead(sms);
    System.assert(String.valueof(sms.Lead__c).left(15) == testId2);
  }

  static testMethod void GetDefaultSenderId() {
    System.Assert(SMS_Utilities.GetDefaultSenderId() == '1');
  }

  static testMethod void BogusTestBecauseWeDoNotWantToCallOut() {
    SMS_Utilities.send_bulk_sms_with_template(new Set<String>(), 'templatename', 'sender');
  }
}