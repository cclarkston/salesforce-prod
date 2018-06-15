public with sharing class CeligoTrigger_OpportunityLineItem extends CeligoTrigger {
    //Opportunity ID
    private ID oppId =  null;
    //pricebook ID
    private ID pricebook = null;
    
    //recursion control flags
    public static boolean noBeforeInsert = false;
    public static boolean noAfterInsert = false;
    
    //constructor
    public CeligoTrigger_OpportunityLineItem(SObject[] newobjs, SObject[] oldobjs, TriggerType tt){
        super(newobjs, oldobjs, tt);
        //subclass specific
        if(this.tt == CeligoTrigger.TriggerType.BeforeInsert ||this.tt == CeligoTrigger.TriggerType.AfterInsert || this.tt == CeligoTrigger.TriggerType.AfterUpdate)
        this.oppId = ((OpportunityLineitem)this.newobjs[0]).OpportunityId;
        if(this.tt == CeligoTrigger.TriggerType.AfterDelete)
        this.oppId = ((OpportunityLineitem)this.oldobjs[0]).OpportunityId;
    }
    
    private void NSRunItemGroup(){
        SObject[] rs = [select id from opportunitylineitem where celigo_product_group__c !=null and opportunityId=:this.oppId];
        Opportunity op = new Opportunity(id=this.oppId);
        op.NS_run_item_group__c = (rs.size()>0)?true:false;
        update op;
    }
    
    public override void doBeforeInsert(){
        //if the Description__c is blank, copy from Line Description
        for(SObject o : this.newobjs){
            OpportunityLineItem op = (OpportunityLineItem)o;
            if(op.Description__c == null&&op.Description != null)
                op.Description__c = op.Description;     
        }
        
        //do item group solution
        if(!CeligoTrigger_OpportunityLineItem.noBeforeInsert){
            //do beforeinsert things
            //get a set of budle items
            Map<Id,Id> bundles = this.getItemBundles();
            //get a set of exploded items
            Map<Id,List<SObject>> explodeditems = this.getExplodedItems(bundles);
            
            //Merge the set into the original list
            List<OpportunityLineItem> toInsert_opplineitems= this.mergeSet(explodeditems);
            
            //insert the list
            CeligoTrigger_OpportunityLineItem.noBeforeInsert = true;
            CeligoTrigger_OpportunityLineItem.noAfterInsert = true;
            if(toInsert_opplineitems!=null && toInsert_opplineitems.size()>0)
            insert toInsert_opplineitems;
        }
        CeligoTrigger_OpportunityLineItem.noBeforeInsert = false;
    }
    
    public override void doAfterInsert(){
        this.NSRunItemGroup();
        if(!CeligoTrigger_OpportunityLineItem.noAfterInsert){
            this.removeDefaultInsert();
        }
        CeligoTrigger_OpportunityLineItem.noAfterInsert = false;
    }
    
    public override void doAfterUpdate(){
        this.NSRunItemGroup();
    }
    
    public override void doAfterDelete(){
        this.NSRunItemGroup();
    }    
    
    private void removeDefaultInsert(){
        List<OpportunityLineItem> dl = [select Id from OpportunityLineItem where remove__c = true];
        //for debug
        System.debug('found to delete '+dl.size()+' records.'); 
        //delete
        if(dl.size()>0)
        delete dl;
    }
    
    private Map<Id/*groupId*/,Id/*pricebookentry*/> getItemBundles(){
        //null check
        if(this.newobjs.size()<1) return null;
        
        Map<Id,Id> product_pbe = new Map<Id,Id>();
        Map<Id,Id> productgroup_pbe = new Map<Id,Id>();
        
        //filter on the list of pricebookentryId
        List<Id> id =  new List<id>();
        for(SObject ob: this.newobjs)id.add((ID)ob.get('PricebookEntryId'));
        //issue SOQL
        for(SObject ob: [SELECT Id, Product2Id, Pricebook2Id FROM PriceBookEntry WHERE Id IN :id]){
            //set the current pricebook
            if(this.pricebook==null)this.pricebook =(Id)ob.get('Pricebook2Id');
            //create map from productId to pricebookentryId
            product_pbe.put((Id)ob.get('Product2Id'),(Id)ob.get('ID'));
        }
        
        //create map from productgroup to pricebookentry
        for(Product_group__c ob:[select Id, product__c from Product_group__c where product__c IN :product_pbe.keyset()]){
            productgroup_pbe.put(ob.Id,product_pbe.get(ob.product__c));
        }
        return productgroup_pbe;
    }
    
    private Map<Id/*group pricebookentryId*/,List<OpportunityLineItem>> getExplodedItems(Map<Id,Id> bundles){
        //null check
        if(bundles==null || bundles.size()<1)return null;
        
        Map<Id,List<SObject>> explodeditems = new Map<Id,List<SObject>>();
        Set<Id> productIds = new Set<Id>();
        
        //filter on bundle id
        Set<Id> id = bundles.keySet();
        //issue SOQL, create new opportunitylineitem and add to explodeditems set
        for(Product_Group_Member__c ob :[
                SELECT 
                Id, Product__c, Product__r.Name, Quantity__c, Order__c, Product_Description__c, Product_Group__c, 
                Product_Group__r.Description__c,Product_Group__r.Name 
                FROM Product_Group_Member__c WHERE Product_Group__c IN :id ORDER BY Order__c, Product__r.Name
            ]){
                
            Id groupId = ob.Product_Group__c;
            //find the pricebookentry id from the bundles mapping and use it as the key for the exploded set
            Id groupPbe = bundles.get(groupId);         
            //throw an exception if the look up failed
            if(groupPbe==null){
                throw new CeligoUnexpectedValueException('Unexpected Product_Group Id');
            }else{
                
                //put in the productId in a set
                productIds.add(ob.Product__c);
                
                //create new opportunitylineitem
                OpportunityLineItem  oli =  new OpportunityLineItem();
                
                //borrow the pricebookentryId field to store the productId
                oli.PricebookEntryId = ob.Product__c;
                oli.Quantity = ob.Quantity__c;
                oli.Celigo_Product_Group__c = groupId;
                oli.Celigo_Product_Group_Internal_Order__c = ob.Order__c;
                
                if(explodeditems.get(groupPbe)==null){
                    //add the entry and initial the list associated
                    List<OpportunityLineItem> newlist = new List<OpportunityLineItem>();
                    explodeditems.put(groupPbe,newlist);
                    //add the current record to the list
                    newlist.add(oli);
                }else{
                    //just add teh record
                    explodeditems.get(groupPbe).add(oli);
                }
            }
        }
        
        //get the pricebookentry for exploded item to ensure the price is available
        Map<Id,PricebookEntry> product_pbe = new Map<Id,PricebookEntry>();
        
        List<PricebookEntry> l = [select Id,Product2Id,Unitprice, IsActive from PricebookEntry where Pricebook2Id = :this.pricebook and product2Id in :productIds];
        //check if any member item is missing pricebookentry
        if(l.size()<productIds.size()){
            String m = 'The following member products are missing pricebook entries: ';
            //find the first product that has no pbe
            for(PricebookEntry ob: l ){
                if(productIds.contains(ob.Product2Id)){
                    productIds.remove(ob.Product2Id);
                }
            }
            if(productIds.size()>0){
                Integer i = 0;
                for(Product2 p:[select name from product2 where Id in:productIds]){
                    m += p.name;
                    i++;
                    if(i!=productIds.size())m +=',';else m+='.';
                }   
            }
            
            this.newobjs[0].addError(m);
            return null;
            
        }else{
            for(PricebookEntry ob:l){
                //check if the price is active
                if(!ob.IsActive){
                    String pn = [select name from product2 where Id = :ob.product2Id][0].Name;
                    this.newobjs[0].addError('Product "'+pn+'" does not have an active price for the current pricebook.');
                    return null;
                }
                //map the productId to the pricebookentryId
                product_pbe.put(ob.Product2Id,ob);          
            }
        
            //update the explodeditems, put in the pricebookentryid
            for(Id i:explodeditems.keySet()){
                List<OpportunityLineItem> templist = explodeditems.get(i);
                for(OpportunityLineItem ob: templist){
	                PricebookEntry pbe = product_pbe.get(ob.PricebookEntryId);
	                ob.PricebookEntryId = pbe.Id;
	                ob.Unitprice = pbe.UnitPrice;
                }
            }
        
            //return the explodeditems
            return explodeditems;
        }
        
    }
    
    private List<OpportunityLineItem> mergeSet(Map<Id,List<SObject>> detail){
        //null check
        if(detail==null || detail.size()<1)return null;
        
        //need a empty list to add into
        List<OpportunityLineItem> result = new List<OpportunityLineItem>();
        
        //iterate through master, if find the pricebookentryId in the detail key set, merge
        for(OpportunityLineItem ob:(List<OpportunityLineItem>)this.newobjs){
            
            //get the master's pricebookentry
            Id pbe = ob.PricebookEntryId;
            Double gquant = ob.Quantity;
            if(detail.get(pbe)!=null){
                //ob is a product group, need to merge
                OpportunityLineItem ob1 = ob.clone(false,true);
                //mark this one as to delete in 'remove__c'
                ob.Description = 'to remove';
                ob.remove__c = true;
                
                //explode into members
                List<OpportunityLineItem> templist = detail.get(pbe);
                //iterate through the templist, clone the group item for custom fields, calculate quanitity
                for(OpportunityLineItem obj: templist){
                    OpportunityLineItem newitem = ob1.clone(false,true);
                    newitem.PricebookEntryId = obj.PricebookEntryId;
                    newitem.Description = obj.Description;
                    newitem.Quantity = obj.Quantity*gquant;
                    newitem.TotalPrice = null;
                    newitem.UnitPrice = obj.unitprice;
                    //add the calculate the member quantity
                    newitem.Celigo_Product_Group__c = obj.Celigo_Product_Group__c;
                    //store the group quantity for netsuite 
                    newitem.Celigo_Product_Group_Quantity__c = gquant;
                    //store the internal order
                    newitem.Celigo_Product_Group_Internal_Order__c = obj.Celigo_Product_Group_Internal_Order__c;      
                    
                    //add the detail line to the result                 
                    result.add(newitem);
                }
                
            }
        }
        
        //for debug
        integer counter=0;
        for(OpportunityLineItem o:result){
            counter++;
            System.debug(o.PricebookEntryId);
        }
        System.debug('total to insert ='+counter);  
        System.debug('size of list '+result.size());
        return result;
    }
}