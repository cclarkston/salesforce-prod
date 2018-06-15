/*
2016-07-05 Alon Waisman
Utilities - 100%
*/

@isTest
private class test_SMS_Utilities {

    static testMethod void test_bulk_SMS() {
        Set<String> phones = new Set<String>{'1234567890', '0987654321'};
        String message     = 'Testing bulk messages.';
        String sender      = 'The Management';
        system.assert(SMS_Utilities.send_bulk_sms(phones, message, sender).contains('<vstatus>success</vstatus>'));
    }

}