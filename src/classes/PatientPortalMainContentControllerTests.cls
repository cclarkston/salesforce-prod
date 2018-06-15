/*
06/10/2018  CC  Inital commit
*/

@isTest
public class PatientPortalMainContentControllerTests {
    @testSetup static void CreateTestAccountAndCenter() {
        List<Account> accounts = new List<Account>();
 		//Create account
        Account account = TestDataFactory.CreateTestAccount();
        account.phone = '(303) 987-2314';
        accounts.add(account);
        insert accounts;
    }
    
    @isTest static void GetAccountTest() {
        Account dbAccount = [SELECT Id
                           		FROM Account
                            	Limit 1];
        Account account = PatientPortalMainContentController.getAccountInfo(dbAccount.Id);
        System.assert(account.phone == '(303) 987-2314');
    }

    @isTest static void GetCenterTest() {
        Center_Information__c dbCenter = [SELECT Id
                           		FROM Center_Information__c
                            	Limit 1];
        Center_Information__c center = PatientPortalMainContentController.getCenterInfo(dbCenter.Id);
        System.assert(center.Name == 'Test Center');
    }
}