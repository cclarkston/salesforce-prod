@isTest
private class testCeligoSObjectDescribe {

    static testMethod void myUnitTest() {
        Test.startTest();
       //assertions
       System.assertEquals(true, CeligoSObjectDescribe.existsSObj('Account'));
       System.assertEquals(true, CeligoSObjectDescribe.existsSObj('account'));
       System.assertEquals(true, CeligoSObjectDescribe.existsSObj('Opportunity'));
       System.assertEquals(true, CeligoSObjectDescribe.existsSObj('opportunity'));
       System.assertEquals(true, CeligoSObjectDescribe.existsSObj('product_group__c'));
       System.assertEquals(false, CeligoSObjectDescribe.existsSObj('mygroup__c'));
       
       System.assertEquals(false, CeligoSObjectDescribe.existsSObjField('a.name'));
       System.assertEquals(false, CeligoSObjectDescribe.existsSObjField('product_group_member__c.quantity'));
       System.assertEquals(false, CeligoSObjectDescribe.existsSObjField('a.name.ff'));
       System.assertEquals(false, CeligoSObjectDescribe.existsSObjField('account.sssss.name'));
       System.assertEquals(false, CeligoSObjectDescribe.existsSObjField('a__fdafjdalfjdaoname'));
       
       System.assertEquals(false, CeligoSObjectDescribe.isCreateable('product_group__c.description'));
       System.assertEquals(false, CeligoSObjectDescribe.isCreateable('productdescription'));
       System.assertEquals(false, CeligoSObjectDescribe.isCreateable('opportunityLineItem.sortorder'));
       
       System.assertEquals(false, CeligoSObjectDescribe.isUpdateable('product_group__c.description'));
       System.assertEquals(false, CeligoSObjectDescribe.isUpdateable('productdescription'));
       System.assertEquals(false, CeligoSObjectDescribe.isUpdateable('opportunityLineItem.sortorder'));
       
       System.assertEquals(false, CeligoSObjectDescribe.isAccessible('product_group__c.description'));
       System.assertEquals(false, CeligoSObjectDescribe.isAccessible('productdescription'));
       System.assertEquals(true, CeligoSObjectDescribe.isAccessible('opportunityLineItem.sortorder'));
       System.assertEquals(true, CeligoSObjectDescribe.isAccessible('Product_Group__c.product__c'));
       
       System.assertEquals(false, CeligoSObjectDescribe.isNillable('opportunityLineItem.id'));
       System.assertEquals(true, CeligoSObjectDescribe.isNillable('opportunityLineItem.sortorder'));
       
       
       System.assertEquals(Schema.DisplayType.ID, CeligoSObjectDescribe.getType('opportunityLineItem.id'));
       System.assertEquals(Schema.DisplayType.Picklist, CeligoSObjectDescribe.getType('opportunity.stagename'));
       System.assertEquals(Schema.DisplayType.Currency, CeligoSObjectDescribe.getType('account.annualrevenue'));
       
       List <Schema.PicklistEntry> vals1 = CeligoSObjectDescribe.getPicklistValues('opportunity.stagename');
       List <Schema.PicklistEntry> vals2 = CeligoSObjectDescribe.getPicklistValues('opportunity.id');
       System.assert(vals2.size()==0);
       System.assertNotEquals(null,vals1);
       system.assert(vals1.size()>1);
       
       Test.stopTest();
    }
}