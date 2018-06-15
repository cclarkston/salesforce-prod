/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class testCeligoExplodeItemBundle {

     static testMethod void myUnitTest() {
        List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Product_Group_Member__c> membersToInsert = new List<Product_Group_Member__c>();
        List<PricebookEntry> pbeToInsert = new List<PricebookEntry>();
        
        Double memberPrices = 0.0;
        Account a1 = new Account(
            //Name = 'TestResellerName',
            Type = 'Student'
        );
         //fill fields defined in the setting
        CeligoTestHelper.fillSobject(a1);
        insert a1;
        
        Pricebook2 s = [select id from Pricebook2 where IsStandard = true];  
        
        Pricebook2 c = new Pricebook2();
        c.IsActive = true;
        c.Name = 'CustomPriceBook';
        
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(c);
        insert c;
        
        Product_Group__c pgroup = new Product_Group__c(
            Name='Test Bundle'
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pgroup);
        insert pgroup;
        
        Product2 member1 = new Product2(
            name='Test Member 1',
            IsActive=true,
            Description='My Product',
            ProductCode='12345'
        );
        productsToInsert.add(member1);
       
        Product2 member2 = new Product2(
            name='Test Member 2',
            IsActive=true,
            Description='My Test Product 2',
            ProductCode='54322'
        );
        
        productsToInsert.add(member2);
        
        Product2 group1 = new Product2(
            name='Test Group',
            IsActive=true,
            Description='My Group',
            ProductCode='987654'
        );
        
        productsToInsert.add(group1);
        
        Product2 nongroup1 = new Product2(
            name='Test Normal',
            IsActive=true,
            Description='My Normal',
            ProductCode='45678'
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(nongroup1);
        productsToInsert.add(nongroup1);
        
        insert productsToInsert;
        
        pgroup.product__c = group1.id;
        update pgroup;
        
        
        Product_Group_Member__c gm1 = new Product_Group_Member__c(
            Product__c=member1.Id,
            Product_Group__c=pgroup.Id,
            Quantity__c=2.0
        );
        
        membersToInsert.add(gm1);
        
        Product_Group_Member__c gm2 = new Product_Group_Member__c(
            Product__c=member2.Id,
            Product_Group__c=pgroup.Id,
            Quantity__c=3.0
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(gm2);
        membersToInsert.add(gm2);
        insert membersToInsert;
        
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id=s.id,
            Product2Id=group1.id,
            UnitPrice=10.66,
            IsActive=true,
            UseStandardPrice=false
        );
        
        pbeToInsert.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id=s.id,
            Product2Id=nongroup1.id,
            IsActive=true,
            UnitPrice=5.00,
            UseStandardPrice=false
        );
        
        pbeToInsert.add(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry(
            Pricebook2Id=s.id,
            Product2Id=member1.id,
            UnitPrice=2.01,
            IsActive=true,
            UseStandardPrice=false
        );
        memberPrices += pbe3.UnitPrice * 2;
        pbeToInsert.add(pbe3);
        
        PricebookEntry pbe4 = new PricebookEntry(
            Pricebook2Id=s.id,
            Product2Id=member2.id,
            UnitPrice=2.21,
            IsActive=true,
            UseStandardPrice=false
        );
        memberPrices += pbe4.UnitPrice * 3;
        pbeToInsert.add(pbe4);
        
        PricebookEntry pbc2 = new PricebookEntry(
            Pricebook2Id=c.id,
            Product2Id=nongroup1.id,
            IsActive=true,
            UnitPrice=6.00,
            UseStandardPrice=false
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pbc2);
        pbeToInsert.add(pbc2);
        
        insert pbeToInsert;
        
        // create the opportunity
        Opportunity opp1 = new Opportunity(
            AccountId=a1.Id,
            name='Test Opp 1',
            StageName = 'Identify',
            CloseDate = Date.newInstance(2009,01,01)            
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(opp1);
        insert opp1;
   
        Date startDate = Date.today();
        Date endDate = startDate.addYears(1);
        
        OpportunityLineItem oli = new OpportunityLineItem(
        Quantity = 1,
        UnitPrice = 10.66,
        PricebookEntryId = pbe1.id,
        OpportunityId = opp1.id
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(oli);
        
        OpportunityLineItem oli2 = new OpportunityLineItem(
        Quantity = 2,
        UnitPrice = 5.3333,
        PricebookEntryId = pbe2.id,
        OpportunityId = opp1.id
        );
          //fill fields defined in the setting
        CeligoTestHelper.fillSobject(oli2);
        memberPrices += oli2.UnitPrice * 2;
        Test.startTest();
        
        olisToInsert.add(oli);
        olisToInsert.add(oli2);
        insert olisToInsert;   
        
        List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity Where Id =:opp1.Id];

        List<OpportunityLineItem> olis = [SELECT Id, PricebookEntryId, UnitPrice, Quantity FROM OpportunityLineItem WHERE OpportunityId = :opp1.Id];
        System.assertEquals(olis.size(), 3);
        
        oli2.Quantity = 3;
        update oli2;
        
        delete oli2;
        
        Test.stopTest();    
    }
}