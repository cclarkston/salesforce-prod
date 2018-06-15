public with sharing class CeligoAccountSyncPoller extends CeligoSyncPoller {
	
	public override String getMessage(){
		return 'Synchronizing...';
	}
	
	public override String getErrorMessage(){
		return 'No Errors';
	}
	
    public PageReference checkSyncStatus(){
           
        Account acct = getAccountById(System.currentPageReference().getParameters().get('whence'));
        if(acct != null){
            System.debug('now: '+System.now());
            System.debug('ns pull: '+acct.NetSuite_Pull__c);
            
            if(acct.NetSuite_Pull__c == false){
                return redirect('apex/sync_complete'); 
            }
        }
        return null;
    }
    
}