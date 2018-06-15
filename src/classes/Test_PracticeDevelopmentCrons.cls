/*
10/17/16
Alon Waisman
Classes:
  PracticeDevelopment_Schedule_Inactive - 100%;
  PracticeDevelopmentCrons - 95%;
*/

@isTest
public class Test_PracticeDevelopmentCrons {

    static testMethod void test_active_practice_switches_to_inactive_if_there_are_no_referrals_younger_than_30_days_old() {
        String practice_status = 'Active';
        Boolean PSA_contract_completed = true;
        Boolean old_opportunity        = true;
        Dental_Practice__c test_practice = new_practice(practice_status, PSA_contract_completed);
        Account test_account             = new_account(test_practice);
        Opportunity test_opportunity     = new_opportunity(test_account, old_opportunity);

        final String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
            System.assertEquals(practice_status, test_practice.Practice_Status__c);
            String jobId = System.schedule('ScheduleTest', CRON_EXP, new PracticeDevelopment_Schedule_Inactive());
        Test.stopTest();

        test_practice = [SELECT Practice_Status__c FROM Dental_Practice__c LIMIT 1];
        System.assertEquals('Inactive', test_practice.Practice_Status__c);
    }

    static testMethod void test_active_no_psa_practice_switches_to_inactive_no_psa_if_there_are_no_referrals_younger_than_30_days_old() {
        String practice_status = 'Active (No PSA)';
        Boolean PSA_contract_completed = false;
        Boolean old_opportunity        = true;
        Dental_Practice__c test_practice = new_practice(practice_status, PSA_contract_completed);
        Account test_account             = new_account(test_practice);
        Opportunity test_opportunity     = new_opportunity(test_account, old_opportunity);

        final String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
            System.assertEquals(practice_status, test_practice.Practice_Status__c);
            String jobId = System.schedule('ScheduleTest', CRON_EXP, new PracticeDevelopment_Schedule_Inactive());
        Test.stopTest();

        test_practice = [SELECT Practice_Status__c FROM Dental_Practice__c LIMIT 1];
        System.assertEquals('Inactive (No PSA)', test_practice.Practice_Status__c);
    }

    static testMethod void test_active_no_psa_practice_switches_to_inactive_if_there_are_no_referrals_younger_than_30_days_old_and_PSA_Contract_Completed_is_true() {
        String practice_status = 'Active (No PSA)';
        Boolean PSA_contract_completed = true;
        Boolean old_opportunity        = true;
        Dental_Practice__c test_practice = new_practice(practice_status, PSA_contract_completed);
        Account test_account             = new_account(test_practice);
        Opportunity test_opportunity     = new_opportunity(test_account, old_opportunity);

        final String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
            System.assertEquals(practice_status, test_practice.Practice_Status__c);
            String jobId = System.schedule('ScheduleTest', CRON_EXP, new PracticeDevelopment_Schedule_Inactive());
        Test.stopTest();

        test_practice = [SELECT Practice_Status__c FROM Dental_Practice__c LIMIT 1];
        System.assertEquals('Inactive', test_practice.Practice_Status__c);
    }

    static testMethod void test_active_practice_stays_active_if_there_are_any_referrals_younger_than_30_days_old() {
        String practice_status = 'Active';
        Boolean PSA_contract_completed = true;
        Boolean old_opportunity        = false;
        Dental_Practice__c test_practice = new_practice(practice_status, PSA_contract_completed);
        Account test_account             = new_account(test_practice);
        Opportunity test_opportunity     = new_opportunity(test_account, old_opportunity);

        final String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
            System.assertEquals(practice_status, test_practice.Practice_Status__c);
            String jobId = System.schedule('ScheduleTest', CRON_EXP, new PracticeDevelopment_Schedule_Inactive());
        Test.stopTest();

        test_practice = [SELECT Practice_Status__c FROM Dental_Practice__c LIMIT 1];
        System.assertEquals('Active', test_practice.Practice_Status__c);
    }


            private static Dental_Practice__c new_practice(String practice_status, Boolean PSA_contract_completed) {
                Dental_Practice__c practice = new Dental_Practice__c(Practice_Status__c = practice_status, PSA_Contract_Completed__c = PSA_contract_completed);
                insert practice;
                return practice;
            }

            private static Account new_account(Dental_Practice__c practice) {
                Account account = new Account(Referral_Office__c = practice.ID,
                                              FirstName = 'Test', LastName = 'User');
                insert account;
                return account;
            }

            private static Opportunity new_opportunity(Account account, Boolean old) {
                Date prosth_exam_paid_date = old ? Date.today().addDays(-31) : Date.today().addDays(-30);
                Opportunity opportunity = new Opportunity(AccountID = account.ID, Prosth_Exam_Paid_Date__c = prosth_exam_paid_date,
                                                          Name = 'Test Opportunity', Final_Referral_Track__c = 'Test Track', StageName = 'Test Stage', CloseDate = prosth_exam_paid_date);
                insert opportunity;
                return opportunity;
            }
}