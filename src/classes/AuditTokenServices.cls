global class AuditTokenServices {

    webservice static String clear_token(ID token_ID, String user_first_name, String user_last_name) {
        Audit_Token__c token = [SELECT Description__c, Extend_Pending_Cancel__c, Prostho_Exam__c FROM Audit_Token__c WHERE ID = :token_ID];
		Datetime now = Datetime.now();
        token.Extend_Pending_Cancel__c = null;
        token.Prostho_Exam__c = null;
        String token_description = (token.Description__c != null) ? ', \'' + token.Description__c + '\',' : '';
        token.Notes__c = 'Token' + token_description + ' manually cleared by ' + user_first_name + ' ' + user_last_name + ' on ' + now.format() + '.';
        try {update token; return 'Token cleared!';} catch (DMLException error) {return 'Something went wrong: ' + error.getMessage();}
    }
}