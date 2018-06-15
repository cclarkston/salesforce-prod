global class PracticeDevelopmentCrons {

    public static void set_dental_practice_statuses_to_inactive() {
        Dental_Practice__c[] active_practices     = active_practices();
        Opportunity[] recent_opportunities        = recent_opportunities(active_practices);
        Set<ID> practices_that_should_stay_active = practices_that_should_stay_active(recent_opportunities);

        for (Dental_Practice__c practice : active_practices) {
            if (practice_is_inactive(practice, practices_that_should_stay_active)) {practice.Practice_Status__c = (practice.PSA_Contract_Completed__c == true) ? 'Inactive' : 'Inactive (No PSA)';}
        }
        try                     {update active_practices;}
        catch (Exception error) {Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();            message.setReplyTo('software-dev@clearchoice.com');            message.setSubject('ERROR updating Dental Practices to Inactive during overnight cron');            message.setUseSignature(false);            message.setPlainTextBody('Line: ' + error.getLineNumber() + '\r' + error.getMessage() + '\r' + error.getStackTraceString() + '\r\r' + 'Dental Practices to Update:\r' + active_practices);            message.setToAddresses(new String[] {'software-dev@clearchoice.com'});            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});}
    }

            private static Dental_Practice__c[] active_practices() {
                Set<String> active_statuses = new Set<String>{'Active', 'Active (No PSA)'};
                return [SELECT ID, PSA_Contract_Completed__c FROM Dental_Practice__c WHERE Practice_Status__c IN :active_statuses];
            }

            private static Opportunity[] recent_opportunities(Dental_Practice__c[] active_practices) {
                Date thirty_days_ago = Date.today().addDays(-30);
                return [SELECT ID, Account.Referral_Office__c
                        FROM Opportunity
                        WHERE Account.Referral_Office__c IN :active_practices
                        AND (
                             (Prosth_Exam_Paid_Date__c  = null AND CreatedDate >= :thirty_days_ago)
                             OR
                             (Prosth_Exam_Paid_Date__c != null AND Prosth_Exam_Paid_Date__c >= :thirty_days_ago)
                            )
                       ];
            }

            private static Set<ID> practices_that_should_stay_active(Opportunity[] recent_opportunities) {
                Set<ID> practices_that_should_stay_active = new Set<ID>{};
                for (Opportunity opportunity : recent_opportunities) {
                    practices_that_should_stay_active.add(opportunity.Account.Referral_Office__c);
                }
                return practices_that_should_stay_active;
            }

            private static Boolean practice_is_inactive(Dental_Practice__c practice, Set<ID> practices_that_should_stay_active) {
                return !practices_that_should_stay_active.contains(practice.ID);
            }
}