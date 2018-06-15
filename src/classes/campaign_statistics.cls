/*modified by cm on 2015-08-09
  Old code predating me - I'm just making a small tweak to keep it compliant with current validation rules
*/

public with sharing class campaign_statistics {
    private ApexPages.StandardController controller {get; set;}
	private Campaign myCampaign;
	private Map<String, Decimal> myCampaignTotals = new Map<String, Decimal> {};
	
	public campaign_statistics(ApexPages.StandardController controller) {
        this.controller = controller;
        system.debug(controller);
        Campaign theCampaign = (Campaign)controller.getRecord();
        system.debug(theCampaign);
        String theCampaignId = theCampaign.Id;
        this.myCampaign = [
        	SELECT 
        		Id,
        		NumberOfLeads,
        		NumberOfContacts,
        		Total_Registered__c,
        		Total_Confirmed__c,
        		Total_Guests__c,
        		Total_Confirmed_Guests__c,
        		Total_Attended__c,
        		Total_Confirmed_Members_and_Guests__c,
        		Total_No_Show_Seminar__c,
        		Total_Walk_Ins__c,
        		Total_Scheduled_Consult__c,
        		Total_Attended_Consult__c,
        		Total_No_Show_Consult__c,
        		Total_Started__c,
        		Total_Starts_Lost__c,
        		        		
        		NumberOfOpportunities,
        		AmountAllOpportunities,
        		NumberOfWonOpportunities,
        		Total_Registered_Distinct__c,
        		HierarchyExpectedRevenue,
        		AmountWonOpportunities
        		
        	FROM Campaign 
        	WHERE Id = :theCampaignId LIMIT 1 ];
        	
        	
        Decimal NegotiatedTotalAmount = 0;
        Decimal TotalPayments = 0;
        Decimal RefundPayments = 0;
        Decimal AnticipatedPayments = 0;
        Decimal OutstandingBalance = 0;
        try {
			for(Campaign theCampaignOpportunity : [
		     	Select Id, (
		     		Select 
		     			Negotiated_Total_Amount__c, 
		     			Total_Payments__c, 
		     			Refund_Payments__c, 
		     			Anticipated_Payments__c, 
		     			Outstanding_Balance_incl_anticpated1__c 
		     		From Opportunities) 
		     	From Campaign
		    	WHERE Id = :theCampaignId ]){
				
				for(Opportunity theOppertunity: theCampaignOpportunity.Opportunities){
					NegotiatedTotalAmount += theOppertunity.Negotiated_Total_Amount__c;
					TotalPayments += theOppertunity.Total_Payments__c;
					RefundPayments += theOppertunity.Refund_Payments__c;
					AnticipatedPayments += theOppertunity.Anticipated_Payments__c;
					OutstandingBalance += theOppertunity.Outstanding_Balance_incl_anticpated1__c;
				}
			}
		} catch (queryexception Campaign){
        }
        
        this.myCampaignTotals.put('NegotiatedTotalAmount', NegotiatedTotalAmount);
        this.myCampaignTotals.put('TotalPayments', TotalPayments);
        this.myCampaignTotals.put('RefundPayments', RefundPayments);
        this.myCampaignTotals.put('AnticipatedPayments', AnticipatedPayments);
        this.myCampaignTotals.put('OutstandingBalance', OutstandingBalance);
    }
    public Campaign getCampaign(){
        return this.myCampaign;
    }
    public Decimal getNegotiatedTotalAmount(){
        return this.myCampaignTotals.get('NegotiatedTotalAmount');
    }    
    public Decimal getTotalPayments(){
        return this.myCampaignTotals.get('TotalPayments');
    }    
    public Decimal getRefundPayments(){
        return this.myCampaignTotals.get('RefundPayments');
    }
    public Decimal getAnticipatedPayments(){
        return this.myCampaignTotals.get('AnticipatedPayments');
    }    
    public Decimal getOutstandingBalance(){
        return this.myCampaignTotals.get('OutstandingBalance');
    }
       
    static testMethod void myTest() {
        test.startTest();
        
        Campaign myCampaign = new Campaign(
        	Name = 'Test Campaign'
        	
        );
        insert myCampaign;
        
        
        Market__c m = new Market__c(Name = 'Test Market');
	    Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = '200 E Colfax Ave', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	    insert test_center; 
	    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
        Account test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish');
	    insert test_account;

        Opportunity myOpportunity = new Opportunity();
        myOpportunity.CampaignId = myCampaign.Id;
        myOpportunity.accountid = test_account.id;
        myOpportunity.Name = 'Test';
        myOpportunity.StageName = 'Scheduled';
        myOpportunity.CloseDate = date.newinstance(2012, 1, 1);

        insert myOpportunity;

        PageReference pageRef = Page.campaign_statistics;
        Test.setCurrentPage(pageRef);
                
        ApexPages.StandardController sc = new ApexPages.standardController(myCampaign);        
        campaign_statistics API = new campaign_statistics(sc);
        
        Campaign test1 = API.getCampaign();
        Decimal test2 = API.getNegotiatedTotalAmount();
        Decimal test3 = API.getTotalPayments();
        Decimal test4 = API.getRefundPayments();
        Decimal test5 = API.getAnticipatedPayments();
        Decimal test6 = API.getOutstandingBalance();
       
        test.stopTest();
  }
}