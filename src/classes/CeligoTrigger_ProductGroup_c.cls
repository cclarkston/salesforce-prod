public class CeligoTrigger_ProductGroup_c extends CeligoTrigger {
    
    //set
    Set<id> prod;
    Set<id> pg;
    Set<id> s;
    
    public CeligoTrigger_ProductGroup_c(List<SObject> newobjs, List<SObject> oldobjs, CeligoTrigger.TriggerType tt){
        super(newobjs,oldobjs,tt);
        this.prod = new Set<Id>();
        this.pg = new Set<Id>();
        this.s = new Set<id>();
        for(Product_Group__c p:(List<Product_group__c>)this.newobjs){
            this.pg.add(p.Id);
            if(p.product__c!=null)this.prod.add(p.product__c);
        }
    }
    
    //override
    public override void doBeforeInsert(){
        this.checkGroup();
        //this.checkMember();     
    }
    
    //override
    public override void doBeforeUpdate(){
        this.checkGroup();
        //this.checkMember();
    }
    
    private void collectFromDb(){
        if(this.tt == CeligoTrigger.TriggerType.BeforeInsert){
            for(Product_Group__c p:[select Id, product__c from product_group__c where product__c !=null])
            this.s.add(p.product__c);
        }
        if(this.tt == CeligoTrigger.TriggerType.BeforeUpdate){
            //exclude Id in trigger.new
            for(Product_Group__c p:[select Id, product__c from product_group__c where product__c !=null and Id not IN :this.pg])
            this.s.add(p.product__c);
        }
    }
    
    private void checkGroup(){
        this.collectFromDb();
        for(Product_Group__c p:(List<Product_group__c>)this.newobjs){
            if(p.product__c!=null){
                if(this.hasDuplicate(p.product__c))
                p.addError('The product has been assigned to another product group.');
            }
        }
    }
    
    /*
    private void checkMember(){
        Map<Id,Id> m = new Map<Id,Id>();
        for(Product_Group_Member__c pgm:[select product__c,Id from product_group_member__c where product__c IN :this.prod]){
            m.put(pgm.product__c,pgm.Id);
        }
        if(m.size()>0){
            for(Product_Group__c p:(List<Product_group__c>)this.newobjs){
                if(p.product__c!=null && m.get(p.product__c)!=null)p.addError('The product has been assigned to another product group member.');
            }
        }
    }*/
    
    private boolean hasDuplicate(Id i){
        integer l = this.s.size();
        this.s.add(i);
        return this.s.size()==l;
    }
    
}