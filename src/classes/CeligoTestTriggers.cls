@isTest
private class CeligoTestTriggers {
   static testMethod void testTrigger () {
        Account a = new Account();
        //a.Name = 'testAccA';
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(a);
        insert a;
        Account actual = [SELECT id,Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Account where id = :a.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        Account a4 = new Account();
        //a4.Name = 'testAccB';
        a4.NetSuite_Pull__c = true;
         //fill fields defined in the setting
        CeligoTestHelper.fillSobject(a4);
        insert a4;
        actual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Account where id = :a4.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
         
        Contact c = new Contact();
        c.LastName = 'testConA';
        //fill contact fields defined in the setting
        CeligoTestHelper.fillSobject(c);
        insert c;
        Contact cActual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Contact where id = :c.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        Contact c2 = new Contact();
        c2.LastName = 'testConB';
        c2.Celigo_Update__c = true;
         //fill fields defined in the setting
        CeligoTestHelper.fillSobject(c2);
        insert c2;
        cActual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Contact where id = :c2.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        c2.LastName = 'testConC';
        update c2;
        cActual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Contact where id = :c2.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        Contact c3 = new Contact();
        c3.LastName = 'testConD';
        c3.NetSuite_Id__c = '-1';
        c3.NetSuite_Locked__c = false;
        //c3.AccountId = a.id;
        
         //fill fields defined in the setting
        CeligoTestHelper.fillSobject(c3);
        insert c3;
        cActual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Contact where id = :c3.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        c3.NetSuite_Id__c = 'testConE';
        update c3;
        cActual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Contact where id = :c3.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        Account a2 = new Account();
        //a2.Name = 'testAccC';
        a2.Celigo_Update__c = true;
        
        //fill account fields defined in the setting
        CeligoTestHelper.fillSobject(a2);
        insert a2;
        actual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Account where id = :a2.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        
        Account a3 = new Account();
        //a3.Name = 'testAccD';
        a3.NetSuite_Id__c = '-1';
        a3.NetSuite_Locked__c = false;
         //fill fields defined in the setting
        CeligoTestHelper.fillSobject(a3);
        insert a3;
        
        actual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                   FROM Account where id = :a3.id];
        System.assert(actual.Celigo_Update__c == false);
        System.assert(actual.NetSuite_Id__c == null);
        System.assert(actual.NetSuite_Locked__c  == false);
        System.assert(actual.NS_Sync__c == null);
        
        Product2 p = new product2(name='Test Product');
         //fill fields defined in the setting
        CeligoTestHelper.fillSobject(p);
        insert p;
        
        System.debug('Success p: ' + p.ID);
        
        Product2 p2 = new product2(name='Test Product2');
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(p2);
        insert p2;
        
        Pricebook2 pb = new pricebook2(name='test pricebook');
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pb);
        insert pb; 
        
        System.debug('Success pb: ' + pb.ID);
        
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        System.debug('Success stdPb: ' + stdPb.ID);
           
        
        PricebookEntry pbeS = new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pbeS);
        insert pbeS;
        System.debug('Success pbeS: ' + pbeS.ID);
          
        PricebookEntry pbeS2 = new PricebookEntry(pricebook2id = stdPb.id, product2id = p2.id, unitprice=100.0, isActive=true);
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pbeS2);
        insert pbeS2;
        System.debug('Success pbeS2: ' + pbeS2.ID);
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=p.id, unitprice=100.0, isActive=true);
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pbe);
        insert pbe;
        System.debug('Success pbe: ' + pbe.ID);
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=pb.id, product2id=p2.id, unitprice=100.0, isActive=true);
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(pbe2);
        insert pbe2;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.AccountId = a3.Id;
        o.StageName = 'Prospecting';
        o.CloseDate = Date.today();
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(o);
        insert o;
        Opportunity oActual = [SELECT id, StageName, Send_to_NetSuite__c, Generate_Estimate__c, Generate_Sales_Order__c, NS_Sync__c
                   FROM Opportunity where id = :o.id];
        System.assert(oActual.Send_to_NetSuite__c == false);
        System.assert(oActual.Generate_Estimate__c == false);
        System.assert(oActual.Generate_Sales_Order__c  == false);
        System.assert(oActual.NS_Sync__c == null);
        System.assert(oActual.StageName == 'Prospecting');
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=o.id, UnitPrice=100, quantity=1, pricebookentryid=pbe.Id);    
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(oli);
        insert oli;
        
        OpportunityLineItem oliActual = [SELECT id, UnitPrice, quantity FROM OpportunityLineItem where id = :oli.id];
        oli.Quantity = 2;
        update oliActual;
        
        NetSuite_Estimate__c estimate = new NetSuite_Estimate__c();
        estimate.Name = 'test';
        estimate.Opportunity__c = o.Id;
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(estimate);
        insert estimate;
        oActual = [SELECT id, Celigo_Sync_Helper__c
                   FROM Opportunity where id = :o.id];
        System.assert(oActual.Celigo_Sync_Helper__c == true);
        
        NetSuite_Sales_Order__c order = new NetSuite_Sales_Order__c();
        order.Name = 'test';
        order.Opportunity__c = o.Id;
        //update Opportunity and fill its fields 
        CeligoTestHelper.fillSobject(o, true);
        update o;
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(order);
        insert order;
        oActual = [SELECT id, StageName, StageNameState__c
                   FROM Opportunity where id = :o.id];
        //get the setting for the closed stage
        celigo_connector__c cs = celigo_connector__c.getInstance('Opportunity Closed Stage');
        String closedStage = (cs!=null)?cs.value__c:'Closed Won';
        System.assert(oActual.StageName == closedStage);
        System.assert(oActual.StageNameState__c == 'Prospecting');
        
        NetSuite_Sales_Order__c so = new NetSuite_Sales_Order__c();
        so.Name = 'testSO';
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(so);
        insert so;
        
        NetSuite_Sales_Order__c so2 = new NetSuite_Sales_Order__c();
        so2.Name = 'test';
        so2.Opportunity__c = o.Id;
        //fill fields defined in the setting
        CeligoTestHelper.fillSobject(so2);
        insert so2;
        oActual = [SELECT id, StageName, StageNameState__c
                   FROM Opportunity where id = :o.id];
        System.assert(oActual.StageName == closedStage );
        System.assert(oActual.StageNameState__c == 'Prospecting');
        
        delete so2;
        
        oActual = [SELECT id, StageName, StageNameState__c
                   FROM Opportunity where id = :o.id];
        System.assert(oActual.StageName == closedStage);
        System.assert(oActual.StageNameState__c == 'Prospecting');
        
        delete order;
        oActual = [SELECT id, StageName, StageNameState__c
                   FROM Opportunity where id = :o.id];
        System.assert(oActual.StageName == 'Prospecting');
        System.assert(oActual.StageNameState__c == null);
        
        CeligoAccountSyncPoller casp = new CeligoAccountSyncPoller();
        casp.getMessage();
        casp.setShowLoader(true);
        casp.getShowLoader();
        casp.getOpportunityById(o.Id);
        casp.getAccountById(a.Id);
        casp.redirect('home/home.jsp');
        System.currentPageReference().getParameters().put('whence', a.Id);
        casp.checkSyncStatus();
        
        CeligoAccountSyncPoller casp3 = new CeligoAccountSyncPoller();
        System.currentPageReference().getParameters().put('whence', a4.Id);
        casp3.checkSyncStatus();
        
        CeligoAccountSyncPoller casp2 = new CeligoAccountSyncPoller();
        casp2.checkSyncStatus();  
        
        a4.NetSuite_Pull__c = false;
        update a4;
        
        casp2.checkSyncStatus();    
        
        CeligoQuoteSyncPoller cqsp = new CeligoQuoteSyncPoller();
        System.currentPageReference().getParameters().put('whence', o.Id);
        cqsp.getMessage();
        cqsp.setShowLoader(true);
        cqsp.getShowLoader();
        cqsp.getOpportunityById(o.Id);
        cqsp.getAccountById(a.Id);
        cqsp.redirect('home/home.jsp');
        cqsp.checkSyncStatus(); 
        
        o.Send_to_NetSuite__c = false;
        o.NS_Sync__c = 'test';
        update o;
        
        cqsp.checkSyncStatus();
        
        CeligoSalesOrderSyncPoller csosp = new CeligoSalesOrderSyncPoller();
        System.currentPageReference().getParameters().put('whence', o.Id);
        csosp.checkSyncStatus();
        System.currentPageReference().getParameters().put('whence', null);
        csosp.checkSyncStatus();
        
        System.currentPageReference().getParameters().put('whence', o.Id);
        System.currentPageReference().getParameters().put('opp_id', o.Id);
        o.Send_to_NetSuite__c = false;
        o.Celigo_Sync_Helper__c = true;
        o.NS_Sync__c = null;
        update o;
        
        System.currentPageReference().getParameters().put('whence', o.Id);
        csosp.checkSyncStatus();
        cqsp.checkSyncStatus();
        
        System.currentPageReference().getParameters().put('whence', 'test_xyz');
        csosp.checkSyncStatus();
        
    }
}