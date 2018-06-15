public with sharing abstract class CeligoSyncPoller {
	
	private Boolean showLoader = true;
    private Boolean showError = false;
    
    public abstract String getMessage();
    public abstract String getErrorMessage();
    
    public Boolean getShowLoader(){
		return showLoader;
	}
	public void setShowLoader(Boolean showLoader){
		this.showLoader = showLoader;
	}
	
	public Boolean getShowError(){
		return showError;
	}
	public void setShowError(Boolean showError){
		this.showError = showError;
	}
    
	public PageReference redirect(String recordId){
		PageReference ref = new PageReference('/'+recordId);
		ref.setRedirect(true);
		return ref;
	}
	
	public Opportunity getOpportunityById(String id){
        return [
            select Id, Celigo_Sync_Helper__c, Send_to_NetSuite__c, NS_Sync__c
            from Opportunity
            where Id =: id
        ];
    }
    
    public Account getAccountById(String id){
        return [
            select Id, NetSuite_Pull__c
            from Account
            where Id =: id
        ];
    }
}