/*
05/22/2018  CC  Inital commit
05/24/2018  CC  Instead of not inserting the record on opt out. Change the status and task outcome. SMS will not be sent
05/29/2018  CC  Call GetOptOutLeadsByPhoneNumber/GetOptOutAccountsByPhoneNumber instead to reduce the number of record and preventing error in prod
05/31/2018  CC  Changed logic to make sure the person has explicitly opt in by checking the Receive_Text_Reminder__c. If not, do not send text.
06/05/2018  CC  Added call to SMS_Utilities.SyncAccountAndLead to sync up references to Account and Lead
06/09/2018  CC  Added userid and senderdefultid as parameter to avoid multiple sosl call
06/11/2018  CC  Added check for Reminder_Text__c 
06/12/2018  CC  Look up all accounts and leads
*/

trigger SMSBefore on smagicinteract__smsMagic__c (before insert) {
  if (trigger.isInsert && trigger.isBefore) {
    List<task> tasks = new List<task>();
    Set<String> phones = new Set<String>();
    List<Id> leadIds = new List<Id>();
    List<Id> accountIds = new List<Id>();
    String defaultSenderId = SMS_Utilities.GetDefaultSenderId();
    String userId = Userinfo.getUserId();

    //Try to match phone number to eiter lead or account
    for (smagicinteract__smsMagic__c  sms : Trigger.new) {
        String phone = Utilities.FormatPhone(sms.smagicinteract__PhoneNumber__c);
        sms = SMS_Utilities.SyncAccountAndLead(sms);
        //Add numbers for looking up account or lead
        phones.add(phone);
        sms.smagicinteract__PhoneNumber__c = phone;
    }   

    //Look for accounts and leads by numbers
    Map<String, Account> accountsPhoneMap = SMS_Utilities.GetAccountsByPhoneNumber(phones);    
    Map<String, Lead> leadsPhoneMap = SMS_Utilities.GetLeadsByPhoneNumber(phones);   

    for (smagicinteract__smsMagic__c  sms : Trigger.new) {
        Boolean sendMessage = false;
        if (accountsPhoneMap.containsKey(sms.smagicinteract__PhoneNumber__c)) {
            Account account = accountsPhoneMap.get(sms.smagicinteract__PhoneNumber__c);
            sms.Account__c = account.Id;  
            sms.smagicinteract__ObjectType__c = 'Account'; 
            //Send if has been explicitly opt in
            if ((account.Receive_Text_Reminder__c == true || account.Reminder_Text__c == Constants.TextReminderTrue) && account.smagicinteract__SMSOptOut__pc != true) {
                sendMessage = true;
            } 
        }
        //No need to look for lead if we have account already
        if (leadsPhoneMap.containsKey(sms.smagicinteract__PhoneNumber__c) && sms.Account__c  == null) {
            Lead lead = leadsPhoneMap.get(sms.smagicinteract__PhoneNumber__c);
            sms.Lead__c = lead.id;
            sms.smagicinteract__ObjectType__c = 'Lead';
            //Send if has been explicitly opt in
            if ((lead.Receive_Text_Reminder__c == true || lead.Reminder_Text__c == Constants.TextReminderTrue) && lead.smagicinteract__SMSOptOut__c != true) {
                sendMessage = true;
            }
        }
        Task task = SMS_Utilities.CreateTaskForSMS(sms, defaultSenderId, userId);
        if (!sendMessage) {
            sms.smagicinteract__sentStatus__c = Constants.MessageNotSentNotOptIn;
            if (task != null) {
                task.Outcome__c = Constants.MessageNotSentNotOptIn;
            }
            sms.smagicinteract__disableSMSOnTrigger__c = 1;
        }
        if(task != null) {
            tasks.add(task);
        }
        sms = SMS_Utilities.SyncAccountAndLead(sms);
    }  
    insert tasks;   
  }
}