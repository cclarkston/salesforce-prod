/*
06/10/2018  CC  Inital commit
*/

public class PatientPortalMainContentController {
    @AuraEnabled
    public static Account getAccountInfo(Id accountId) {
    	Account account = [SELECT Id, Name,Center_Location__c,Center__r.Name,Center__r.Id,Phone
                           	FROM Account
                           	WHERE Id = :accountId
                           	LIMIT 1];
        return account;
    }
    
    @AuraEnabled 
    public static Center_Information__c getCenterInfo(Id centerId) {
        Center_Information__c center = [SELECT Street_1__c, Street_2__c, City__c, State__c, Zip_Code__c, Center_Webpage__c, Map_Directions_URL__c, Local_Front_Desk__c, Name
                        	FROM Center_Information__c
                        	WHERE Id = :centerId
                        	LIMIT 1];
        return center;
    }
    
   	@AuraEnabled
    public static String getBaseUrl(String search){
        return String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
    }
}