public with sharing class CeligoSalesOrderSyncPoller extends CeligoSyncPoller {
    
    private Boolean errorOccurred = false;
    private String errorMessage;
    
    public override String getErrorMessage(){
    	return errorMessage;
    }
    private void setErrorMessage(String errorMessage){
    	this.errorMessage = errorMessage;
    }
    
    private void setErrorOccurred(Boolean errorOccurred){
    	this.errorOccurred = errorOccurred;
    }
    
    public override String getMessage(){
    	if (errorOccurred)
			return 'Generation Failed:';
		
		return 'Generating Order...';
	}
    
    public PageReference checkSyncStatus(){
        
        String recordId = System.currentPageReference().getParameters().get('whence');
        if(recordId == null || recordId.contains('/') || recordId.contains('http') || recordId.contains('.'))
        	return null;
         
        Opportunity opp = null;
        if(System.currentPageReference().getParameters().get('opp_id') != null)  //invoked from Quote
	        opp = getOpportunityById(System.currentPageReference().getParameters().get('opp_id'));
        else  //invoked from Opp
        	opp = getOpportunityById(System.currentPageReference().getParameters().get('whence'));
        	
        if(opp != null){
            System.debug('now: '+System.now());
            System.debug('sync helper: '+opp.Celigo_Sync_Helper__c);
            System.debug('send to NS: '+opp.Send_to_NetSuite__c);
            System.debug('NS sync: '+opp.NS_Sync__c);
            
            if(opp.Send_to_NetSuite__c == false && opp.NS_Sync__c != null){
                setShowLoader(false);
                setErrorOccurred(true);
                setErrorMessage(opp.NS_Sync__c);
            	setShowError(true);
            }
            if((opp.Celigo_Sync_Helper__c == true && opp.Send_to_NetSuite__c == false && opp.NS_Sync__c == null))
                return redirect('apex/sync_complete'); 
        }
        return null;
    }
}