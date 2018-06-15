/*
05/14/2018  CC  Added functions for looking up leads and accounts by phone number
05/22/2018  CC  Changed GetLeadsByPhoneNumber/GetAccountsByPhoneNumber to return lead/account rather than just ids
05/29/2018  CC  Added GetOptOutLeadsByPhoneNumber/GetOutedOutAccountsByPhoneNumber to return lead/account that had opted out to resolve GetLeadsByPhoneNumber/GetAccountsByPhoneNumber timing out in prod
05/31/2018  CC  Added GetOptInLeads
06/07/2018  CC  Added SyncAccountAndLead
06/09/2018  CC  Added userid and senderdefultid as parameter to avoid multiple sosl call
06/11/2018  CC  Added check for Reminder_Text__c
*/

public class SMS_Utilities {
  // String[] the_phones = new String[]{'6027033263', '9707298268'};
  // String the_message = 'testing bulk messages. reply \'STOP\' to do absolutely nothing.';
  // String the_sender = 'CCT Management';
  // String response = send_bulk_sms(the_phones, the_message, the_sender);
    public static String send_bulk_sms(Set<String> phone_numbers, String message, String sender) {
        // Simple bulk sms sender. It just takes a list of numbers, the message to send, and a sender name, and sends the texts to the list of numbers provided.
        smagicinteract__smsmagic__c[] smsObjectList = new smagicinteract__smsmagic__c[]{};
        smagicinteract__smsMagic__c smsObject;

        for (String phone_number : phone_numbers) {
            smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__PhoneNumber__c = phone_number;
            smsObject.smagicinteract__SenderId__c    = sender;
            smsObject.smagicinteract__SMSText__c     = message;
            smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObjectList.add(smsObject);
        }
        return !test.isRunningTest() ? smagicinteract.ApexAPI.pushSMSCallout(smsObjectList) : '<?xml version="1.0"?> <response> <vstatus>success</vstatus> <responseText>All SMSes were queued in single sms standard queue</responseText> </response>';
    }

    public static void send_bulk_sms_with_template(Set<String> phone_numbers, String templateName, String sender) {
        smagicinteract__smsmagic__c[] smsObjectList = new smagicinteract__smsmagic__c[]{};
        smagicinteract__smsMagic__c smsObject;
        smagicinteract__SMS_Template__c template = [SELECT smagicinteract__Text__c
                                                    FROM smagicinteract__SMS_Template__c
                                                    WHERE smagicinteract__Name__c = :templateName
                                                    LIMIT 1];
        for (String phone_number : phone_numbers) {
            smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__PhoneNumber__c = phone_number;
            smsObject.smagicinteract__SenderId__c    = 'CCT Management';
            smsObject.smagicinteract__SMSText__c     = template.smagicinteract__Text__c;
            smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObjectList.add(smsObject);
        }                             
        smagicinteract.ApexAPI.pushSMSCallout(smsObjectList)          ;  
    }

    public static Map<String, Lead> GetLeadsByPhoneNumber(Set<String> leadPhones) {
        Map<String, Lead> leadPhoneMap = new Map<String, Lead>(); 
        for (Lead lead : [SELECT Phone, MobilePhone, Id, smagicinteract__SMSOptOut__c, Receive_Text_Reminder__c, LastName, Reminder_Text__c 
                            FROM Lead 
                            WHERE Phone in :leadPhones or MobilePhone in :leadPhones]) {
            addLeadToMap(leadPhoneMap, lead, leadPhones);
        }
        return leadPhoneMap;
    }

    public static Map<String, Account> GetAccountsByPhoneNumber(Set<String> accountPhones) {
        Map<String, Account> accountPhoneMap = new Map<String, Account>();   
        for (Account account : [SELECT Phone, PersonMobilePhone, Id, smagicinteract__SMSOptOut__pc, Receive_Text_Reminder__c, LastName, Reminder_Text__c
                                FROM Account 
                                WHERE Phone in :accountPhones or PersonMobilePhone in :accountPhones]) {
            addAccontToMap(accountPhoneMap, account, accountPhones); 
        }
        return accountPhoneMap;     
    } 

    public static Map<String, Lead> GetOptOutLeadsByPhoneNumber(Set<String> leadPhones) {
        Map<String, Lead> leadPhoneMap = new Map<String, Lead>(); 
        for (Lead lead : [SELECT Phone, MobilePhone, Id, smagicinteract__SMSOptOut__c, Receive_Text_Reminder__c, LastName 
                            FROM Lead 
                            WHERE (Phone in :leadPhones or MobilePhone in :leadPhones)
                                    AND smagicinteract__SMSOptOut__c = true]) {
            addLeadToMap(leadPhoneMap, lead, leadPhones);
        } 
        return leadPhoneMap;
    }

    public static Map<String, Account> GetOptOutAccountsByPhoneNumber(Set<String> accountPhones) {
        Map<String, Account> accountPhoneMap = new Map<String, Account>();   
        for(Account account : [SELECT Phone, PersonMobilePhone, Id, smagicinteract__SMSOptOut__pc, LastName 
                                FROM Account 
                                WHERE (Phone in :accountPhones or PersonMobilePhone in :accountPhones)
                                        AND smagicinteract__SMSOptOut__pc = true]) {
            addAccontToMap(accountPhoneMap, account, accountPhones);
        }
        return accountPhoneMap;     
    } 

    public static Map<String, Lead> GetOptInLeadsByPhoneNumber(Set<String> leadPhones) {
        Map<String, Lead> leadPhoneMap = new Map<String, Lead>(); 
        for (Lead lead : [SELECT Phone, Id, MobilePhone
                            FROM Lead 
                            WHERE (Phone in :leadPhones or MobilePhone in :leadPhones)
                                    AND smagicinteract__SMSOptOut__c != true
                                    AND (Receive_Text_Reminder__c = true or Reminder_Text__c = :Constants.TextReminderTrue)]) {
            addLeadToMap(leadPhoneMap, lead, leadPhones);
        } 
        return leadPhoneMap;
    }    

    public static Map<String, Account> GetOptInAccountsByPhoneNumber(Set<String> accountPhones) {
        Map<String, Account> accountPhoneMap = new Map<String, Account>();   
        for (Account account : [SELECT Phone, Id, PersonMobilePhone
                                FROM Account 
                                WHERE (Phone in :accountPhones or PersonMobilePhone in :accountPhones)
                                        AND smagicinteract__SMSOptOut__pc != true
                                        AND (Receive_Text_Reminder__c = true or Reminder_Text__c = :Constants.TextReminderTrue)]) {
            addAccontToMap(accountPhoneMap, account, accountPhones);
        }
        return accountPhoneMap;     
    } 

    public static String GetDefaultSenderId() {
        smagicinteract__SenderId_Profile_Map__c senderProfileMap = [SELECT smagicinteract__Default_SenderId__c
                                                                        FROM smagicinteract__SenderId_Profile_Map__c
                                                                        WHERE smagicinteract__Profile_Id__c = :userinfo.getProfileId()
                                                                        LIMIT 1];
        return senderProfileMap.smagicinteract__Default_SenderId__c;
    }

    public static Task CreateTaskForSMS(smagicinteract__smsMagic__c sms) {
        return CreateTaskForSMS(sms, null, null);
    } 

    public static Task CreateTaskForSMS(smagicinteract__smsMagic__c sms, String defaultSenderId, String userId) {
        System.debug('CreateTaskForSMS');
        System.debug(sms);
        String activityType = '';
        String text = 'Text: ';
        Id whoId = null;
        Id whatId = null;
        if (defaultSenderId == null){
            defaultSenderId = GetDefaultSenderId();
        }
        if (userId == null) {
            userId = Userinfo.getUserId();
        }
        if (sms.Lead__c != null) {
            whoId = sms.Lead__c;
        }
        if (sms.Account__c != null) {
            whatId = sms.Account__c;
        }
        if (sms.smagicinteract__senderId__c != null && sms.smagicinteract__senderId__c.equals(defaultSenderId)) {
            activityType = Constants.ManualOutgoingSMSActivityType;            
        }
        else {         
            activityType = Constants.OnlineOutgoingSMSActivityType;
        }
        if (whoId != null) {
            return new Task(WhoId = whoId, OwnerId = userId, Subject = text, Type = 'Other', Activity_Type__c = activityType, Outcome__c = '', Call_No_Answer__c = false, Status = 'Completed');
        }        
        if (whatId != null) {
            return new Task(WhatId = whatId, OwnerId = userId, Subject = text, Type = 'Other', Activity_Type__c = activityType, Outcome__c = '', Call_No_Answer__c = false, Status = 'Completed');
        }
        return null;
    }

    public static smagicinteract__smsMagic__c SyncAccountAndLead(smagicinteract__smsMagic__c sms) {
        if (sms.smagicinteract__Account__c != null) {
            sms.Account__c = sms.smagicinteract__Account__c;
        }
        if (sms.Account__c != null) {
            sms.smagicinteract__Account__c = sms.Account__c;
        }
        if (sms.smagicinteract__Lead__c != null) {
            sms.Lead__c = sms.smagicinteract__Lead__c ;
        }
        if (sms.Lead__c != null) {
            sms.smagicinteract__Lead__c = sms.Lead__c;
        }
        return sms;
    }

    private static Map<String, Lead> addLeadToMap(Map<String, Lead> leadPhoneMap, Lead lead, Set<String> leadPhones) {
        if (lead.Phone != null && leadPhones.contains(lead.Phone)) {
            leadPhoneMap.put(lead.Phone, lead);
        } 
        if (lead.MobilePhone != null && leadPhones.contains(lead.MobilePhone)) {
            leadPhoneMap.put(lead.MobilePhone, lead);
        } 
        return leadPhoneMap;
    }

    private static Map<String, Account> addAccontToMap(Map<String, Account> accountPhoneMap, Account account, Set<String> accountPhones) {
        if (account.Phone != null && accountPhones.contains(account.Phone)) {
            accountPhoneMap.put(account.Phone, account);
        } 
        if (account.PersonMobilePhone != null && accountPhones.contains(account.PersonMobilePhone)) {
            accountPhoneMap.put(account.PersonMobilePhone, account);
        } 
        return accountPhoneMap;
    }
}