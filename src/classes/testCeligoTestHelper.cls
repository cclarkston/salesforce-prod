@isTest
private class testCeligoTestHelper {
    static testMethod void myUnitTest() {
       //insert a setting
       celigo_test_fields__c setting = new celigo_test_fields__c();
       setting.name = 'celigotestsetting';
       setting.test_fields__c = 'amount:1622.22,testfld1:19\\:18\\:20\\:2222';
       insert setting;
       
       //insert a setting for account if not already existing
       celigo_test_fields__c acctsetting;
       acctsetting = celigo_test_fields__c.getInstance('account');
       if(acctsetting==null){
         acctsetting = new celigo_test_fields__c();
         acctsetting.name = 'account';
         acctsetting.test_fields__c = 'type:prospect';
         insert acctsetting;
       }
       //test account object
       Account acctobj = new Account();
       CeligoTestHelper.fillSobject(acctobj);
      
      //test starts
      system.Test.startTest();
      //verify the setting is there
      system.assertEquals('amount:1622.22,testfld1:19\\:18\\:20\\:2222', celigo_test_fields__c.getInstance('celigotestsetting').test_fields__c);
      
      //test for enctyptedString
      //test for multipicklist
      //test for time
      //test for combobox
      
      //get a valid account id
      Id acctid = [select Id from account limit 1][0].Id;
      //test fields string for account
      String acctflds = 'parentId:'+acctid+' ,phone : 8612345670 , type:prospect, accountnumber : testaccount0001 , website : http\\://www.celigo.com , annualrevenue :1000.99,description:tis is a test description\\, and thats all.,,numberofemployees:99,Celigo_Update__c:true';
      //create an account and fill the fields using the string
      Account acct = new Account();
      CeligoTestHelper.fillFields(acct, 'account', acctflds);
      //test for reference
      if(CeligoSObjectDescribe.isUpdateable('Account.parentId'))
      	system.assertEquals(acctid,acct.parentId, 'incorrect account parent id');
      //test for phone
      if(CeligoSObjectDescribe.isUpdateable('Account.Phone'))
        system.assertEquals('8612345670',acct.phone,'incorrect account phone');
      //test for picklist
      if(CeligoSObjectDescribe.isUpdateable('Account.Type'))
        system.assertEquals('prospect',acct.type,'incorrect account type');
      //test for string
      if(CeligoSObjectDescribe.isUpdateable('Account.AccountNumber'))
        system.assertEquals('testaccount0001',acct.AccountNumber, 'incorrect account number');
      //test for textarea
      if(CeligoSObjectDescribe.isUpdateable('Account.Description'))
        system.assertEquals('tis is a test description, and thats all.', acct.description,'incorrect description');
      //test for url
      if(CeligoSObjectDescribe.isUpdateable('Account.Website'))
        system.assertEquals('http://www.celigo.com',acct.website,'incorrect website');
      //test for currency
      if(CeligoSObjectDescribe.isUpdateable('Account.AnnualRevenue'))   
        system.assertEquals(1000.99, acct.annualrevenue,'incorrect annual revenue');
       //test for integer
      if(CeligoSObjectDescribe.isUpdateable('Account.NumberOfEmployees'))
        system.assertEquals(99,acct.numberofemployees,'incorrect number of employees');
       //test for Boolean
      if(CeligoSObjectDescribe.isUpdateable('Account.Celigo_Update__c'))
        system.assertEquals(true,acct.celigo_update__c,'account celigo update c incorrect');
      
      //test string for contact
      String cntctflds = 'email:test@celigo.com,donotcall:true,birthdate:2011-04-30 ,LastCURequestDate:1999-01-01 18\\:00\\:00,';
      //create a contact obj
      Contact c = new Contact();
      //fill fields for contact
      CeligoTestHelper.fillFields(c,'contact',cntctflds);
      //test for email
      if(CeligoSObjectDescribe.isUpdateable('Contact.Email'))
        system.assertEquals('test@celigo.com',c.email,'contact email incorrect');
      //test for date
      if(CeligoSObjectDescribe.isUpdateable('Account.Birthdate'))
        system.assertEquals('4/30/2011',c.birthdate.format(),'birthdate incorrect');
      
      
      //test string for contact
      String oppflds = 'totalopportunityquantity:5555.55,probability:0.75,:,netsuite_sync_time__c:1999-01-01 18\\:10\\:00';
      //create a contact obj
      Opportunity opp = new Opportunity();
      //fill fields for contact
      CeligoTestHelper.fillFields(opp,'opportunity',oppflds);
      //test for double
      if(CeligoSObjectDescribe.isUpdateable('Opportunity.TotalOpportunityQuantity'))
        system.assertEquals(5555.55, opp.totalopportunityquantity,'incorrect total quantity');
      //test for percent
      if(CeligoSObjectDescribe.isUpdateable('Opportunity.Probability'))
        system.assertEquals(0.75,opp.probability, 'incorrect probability');
      //test for date time
      //won't run unless open the field for update in field-level security
      //system.assertEquals('1/1/1999 6:10 PM',opp.netsuite_sync_time__c.format(),'incorrect netsuite sync date/time');
      //test finishes
      system.Test.stopTest();
    }
}