public abstract class CeligoTrigger {
    
    //enum for trigger types
    public enum TriggerType{
        BeforeInsert,AfterInsert,
        BeforeUpdate,AfterUpdate,
        BeforeDelete,AfterDelete,
        AfterUndelete
    }
    
    //member data
    protected SObject[] newobjs;
    protected SObject[] oldobjs;
    protected TriggerType tt;
    
    //parent constructor
    public CeligoTrigger(SObject[] newobjs, SObject[] oldobjs, TriggerType tt){
        //construct
        this.newobjs = newobjs;
        this.oldobjs = oldobjs;
        this.tt = tt;
    }
    
    public void doTrigger(){
        try{
            //do the trigger in the correct context
            if(this.tt==TriggerType.BeforeInsert)this.doBeforeInsert();
            if(this.tt==TriggerType.AfterInsert)this.doAfterInsert();
            if(this.tt==TriggerType.BeforeUpdate)this.doBeforeUpdate();
            if(this.tt==TriggerType.AfterUpdate)this.doAfterUpdate();
            if(this.tt==TriggerType.BeforeDelete)this.doBeforeDelete();
            if(this.tt==TriggerType.AfterDelete)this.doAfterDelete();
            if(this.tt==TriggerType.AfterUndelete)this.doAfterUndelete();
        }catch(CeligoException e){
            //TODO: handle exception
            this.handleCeligoException(e);
        }catch(Exception e){
            //TODO: handle exception
            this.handleException(e);
        }finally{
            this.cleanUp();
        }
    }
    
    //clean up if anything
    protected virtual void cleanUp(){}
    
    //methods for override
    protected virtual void doBeforeInsert(){}
    protected virtual void doAfterInsert(){}
    protected virtual void doBeforeUpdate(){}
    protected virtual void doAfterUpdate(){}
    protected virtual void doBeforeDelete(){}
    protected virtual void doAfterDelete(){}
    protected virtual void doAfterUndelete(){}
    
    //helper function for CeligoException
    protected virtual void handleCeligoException(CeligoException e){
        
    }
    
     //helper function for general Exception
    protected virtual void handleException(Exception e){
       
    }
}