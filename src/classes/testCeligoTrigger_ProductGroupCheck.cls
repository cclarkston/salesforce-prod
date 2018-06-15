@isTest
private class testCeligoTrigger_ProductGroupCheck {

    static testMethod void myUnitTest() {
       //sample some data
       //create some products
       Product2 p1 = new Product2(Name='test1');
       Product2 p2 = new Product2(Name='test2');
       Product2 p3 = new Product2(Name='test3');
       
       CeligoTestHelper.fillSobject(p1);
       insert p1;
       CeligoTestHelper.fillSobject(p2);
       insert p2;
       CeligoTestHelper.fillSobject(p3);
       insert p3;
       
       //create some product groups
       Product_group__c pg1 = new Product_group__c(Name='g1',description__c='test',product__c=p1.id);
       Product_group__c pg2 = new Product_group__c(Name='g2',description__c='test',product__c=p2.id);
       Product_group__c pg3 = new Product_group__c(Name='g3',description__c='test',product__c=p1.id);
       Product_group__c pg4 = new Product_group__c(Name='g1',description__c='test');
       
       integer ct = [select count() from product_group__c where name like 'g%'];
       
       //start test
       Test.starttest();
       //test cases
       	CeligoTestHelper.fillSobject(pg1);
        insert pg1;
        integer ct1 = [select count() from product_group__c where name like 'g%'];
        System.debug('count ct1 ='+ct1);
        System.assertEquals(ct+1,ct1);
        
        CeligoTestHelper.fillSobject(pg2);
        insert pg2;
        integer ct2 = [select count() from product_group__c where name like 'g%'];
        System.debug('count ct2 ='+ct2);
        System.assertEquals(ct+2,ct2);
       	System.debug('pg2 Id is '+pg2.Id );
        try{
        	CeligoTestHelper.fillSobject(pg3);
        	insert pg3;
        }catch(System.DMLException e){
        	system.debug(e.getMessage());
        }
        integer ct3 = [select count() from product_group__c where name like 'g%'];
        System.debug('count ct3 ='+ct3);
        System.assertEquals(ct+2,ct3);
        
        CeligoTestHelper.fillSobject(pg4);
        insert pg4;
        integer ct4 = [select count() from product_group__c where name like 'g%'];
        System.debug('count ct4 ='+ct4);
        System.assertEquals(ct+3,ct4);
        
        //updates
        List<product_group__c> l = new List<Product_group__c>();
        pg2.product__c=p3.Id;
        Pg4.product__c=p3.Id;
        l.add(pg2);
        l.add(pg4);
        update pg2;
        try{
        	update pg4;
        }catch(System.DMLException e){
        	system.debug(e.getMessage());
        	System.debug('p1 Id is: '+p1.Id);
	        System.debug('p2 Id is: '+p2.Id);
	        System.debug('p3 Id is: '+p3.Id);
	        
	        System.debug('pg2.product__c is:'+pg2.product__c);
	        System.debug('pg4.product__c is:'+pg4.product__c);
	        
	        System.assertEquals(p3.Id,pg2.product__c);
        }
        
        Id i = (ID)[select product__c from product_group__c where id=:pg4.Id][0].get('product__c');
        System.assertEquals(null,i);
        
        pg2.product__c=p3.Id;
        Pg4.product__c=p2.Id;
        
        update l;
        System.assertEquals(p3.Id,pg2.product__c);
        System.assertEquals(p2.Id,pg4.product__c);
        
       //stop test
       Test.stoptest();
    }
}